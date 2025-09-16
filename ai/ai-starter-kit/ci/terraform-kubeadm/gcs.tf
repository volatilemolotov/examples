resource "google_storage_bucket" "bucket" {
  project  = var.project_id
  name     = "tf-${var.project_id}-${var.vm_name}-startup-script-files"
  location = "us-central1"
  force_destroy = true
  uniform_bucket_level_access = true
}

resource "google_project_iam_member" "gcs_access" {
  project = var.project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.sa.email}"

  depends_on = [ google_storage_bucket.bucket ]
}
