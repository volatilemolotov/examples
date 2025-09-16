data "google_project" "project" {
  project_id = var.project_id
}

resource "google_service_account" "sa" {
  project = var.project_id
  account_id   = var.sa_account_id
  display_name = var.sa_display_name
}

resource "google_compute_instance" "vm" {
  project      = var.project_id
  name         = var.vm_name
  machine_type = var.vm_machine_type
  zone         = var.vm_zone

  boot_disk {
    initialize_params {
      image = var.vm_image
      size = 300
    }
  }

  network_interface {
    network = "default"
    access_config {
      // Ephemeral public IP
    }
  }

  # metadata_startup_script = file("${path.module}/k8s.sh")#"echo hi > /test.txt"
  metadata_startup_script = templatefile("${path.module}/k8s.sh", { BUCKET_NAME = google_storage_bucket.bucket.name })

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
     email  = google_service_account.sa.email
    scopes = ["cloud-platform"]
  }

  depends_on = [ google_project_iam_member.gcs_access ]
}
