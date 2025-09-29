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