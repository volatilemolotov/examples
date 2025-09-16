output "bucket_name" {
  value = google_storage_bucket.bucket.name
}

output "vm_instance_name" {
  value = google_compute_instance.vm.name
}
