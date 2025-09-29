output "instance_name" {
  description = "Name of the Minikube instance"
  value       = google_compute_instance.minikube_instance.name
}

output "instance_id" {
  description = "ID of the Minikube instance"
  value       = google_compute_instance.minikube_instance.id
}

output "instance_external_ip" {
  description = "External IP of the Minikube instance"
  value       = google_compute_instance.minikube_instance.network_interface[0].access_config[0].nat_ip
}

output "instance_internal_ip" {
  description = "Internal IP of the Minikube instance"
  value       = google_compute_instance.minikube_instance.network_interface[0].network_ip
}

output "zone" {
  description = "Zone of the Minikube instance"
  value       = var.zone
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "gcloud compute ssh ${var.ssh_user}@${google_compute_instance.minikube_instance.name} --zone=${var.zone} --project=${var.project_id}"
}

output "service_account_email" {
  description = "Service account email for the instance"
  value       = google_service_account.minikube_sa.email
}