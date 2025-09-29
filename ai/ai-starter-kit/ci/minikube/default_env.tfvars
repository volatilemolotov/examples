project_id = "akvelon-gke-aieco"
region     = "us-central1"
zone       = "us-central1-a"

ssh_user          = "ubuntu"
ssh_public_key    = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDXDyEOZ9AFA0JxGKW6IhnJNKb2qvM+MY/BTZRz76dFI alek@MacBook-Pro.local"  # Add your SSH public key here
ssh_source_ranges = ["0.0.0.0/0"]  # Restrict this in production

instance_name   = "ai-starter-minikube"
machine_type    = "n2-standard-4"
boot_disk_size  = 30
boot_disk_type  = "pd-ssd"

network    = "default"
subnetwork = ""

kubectl_source_ranges   = ["0.0.0.0/0"]  # Restrict this in production

minikube_version   = "latest"
kubernetes_version = "v1.28.3"
minikube_driver    = "docker"
minikube_cpus      = 2
minikube_memory    = "4096"
minikube_disk_size = "20g"
container_runtime  = "docker"

labels = {
  environment = "dev"
  managed_by  = "terraform"
  purpose     = "ai-starter-kit"
  team        = "platform"
}