resource "google_service_account" "minikube_sa" {
  account_id   = "${var.instance_name}-sa"
  display_name = "Service Account for Minikube Instance"
  project      = var.project_id
}

resource "google_project_iam_member" "minikube_sa_roles" {
  for_each = toset([
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer"
  ])
  
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.minikube_sa.email}"
}

resource "google_compute_firewall" "ssh_access" {
  name    = "${var.instance_name}-ssh-access"
  network = var.network
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.ssh_source_ranges
  target_tags   = ["minikube-instance"]
}

resource "google_compute_firewall" "kubectl_access" {
  count   = var.enable_external_kubectl ? 1 : 0
  name    = "${var.instance_name}-kubectl-access"
  network = var.network
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["8443"]
  }

  source_ranges = var.kubectl_source_ranges
  target_tags   = ["minikube-instance"]
}

resource "google_compute_instance" "minikube_instance" {
  name         = "${var.instance_name}-minikube-instance"
  machine_type = var.machine_type
  zone         = var.zone
  project      = var.project_id

  tags = ["minikube-instance"]

  boot_disk {
    initialize_params {
      image = var.boot_disk_image
      size  = var.boot_disk_size
      type  = var.boot_disk_type
    }
  }

  network_interface {
    network    = var.network
    subnetwork = var.subnetwork

    access_config {}

  }

  service_account {
    email  = google_service_account.minikube_sa.email
    scopes = ["cloud-platform"]
  }

  metadata = {
    ssh-keys = var.ssh_public_key != "" ? "${var.ssh_user}:${var.ssh_public_key}" : null
  }

  metadata_startup_script = templatefile("${path.module}/scripts/install_minikube.sh", {
    MINIKUBE_VERSION    = var.minikube_version
    KUBERNETES_VERSION  = var.kubernetes_version
    DRIVER             = var.minikube_driver
    CPUS               = var.minikube_cpus
    MEMORY             = var.minikube_memory
    DISK_SIZE          = var.minikube_disk_size
    CONTAINER_RUNTIME  = var.container_runtime
  })

  allow_stopping_for_update = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "time_sleep" "wait_for_instance" {
  depends_on = [google_compute_instance.minikube_instance]

  create_duration = "120s"
}

data "google_compute_instance" "minikube_instance" {
  name    = google_compute_instance.minikube_instance.name
  zone    = var.zone
  project = var.project_id

  depends_on = [time_sleep.wait_for_instance]
}

resource "null_resource" "get_kubeconfig" {
  depends_on = [time_sleep.wait_for_instance]

  triggers = {
    instance_id = google_compute_instance.minikube_instance.id
  }

  provisioner "local-exec" {
    command = <<-EOT
      gcloud compute ssh ${var.ssh_user}@${google_compute_instance.minikube_instance.name} \
        --zone=${var.zone} \
        --project=${var.project_id} \
        --command="sudo cat /root/.kube/config" > ${path.module}/kubeconfig-${google_compute_instance.minikube_instance.name}.yaml 2>/dev/null || \
      gcloud compute ssh ${var.ssh_user}@${google_compute_instance.minikube_instance.name} \
        --zone=${var.zone} \
        --project=${var.project_id} \
        --command="cat ~/.kube/config" > ${path.module}/kubeconfig-${google_compute_instance.minikube_instance.name}.yaml
      
      # Update the server address to use external IP
      if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s|server: https://.*:8443|server: https://${google_compute_instance.minikube_instance.network_interface[0].access_config[0].nat_ip}:8443|g" ${path.module}/kubeconfig-${google_compute_instance.minikube_instance.name}.yaml
      else
        sed -i "s|server: https://.*:8443|server: https://${google_compute_instance.minikube_instance.network_interface[0].access_config[0].nat_ip}:8443|g" ${path.module}/kubeconfig-${google_compute_instance.minikube_instance.name}.yaml
      fi
    EOT
  }
}