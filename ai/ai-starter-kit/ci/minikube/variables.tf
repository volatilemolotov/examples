variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP Zone"
  type        = string
  default     = "us-central1-a"
}

variable "instance_name" {
  description = "Name prefix for the Minikube instance"
  type        = string
  default     = "minikube"
}

variable "machine_type" {
  description = "Machine type for the GCP instance"
  type        = string
  default     = "n2-standard-4"
}

variable "network" {
  description = "VPC network name"
  type        = string
  default     = "minikube-instance"
}

variable "subnetwork" {
  description = "VPC subnetwork name"
  type        = string
  default     = ""
}

variable "boot_disk_image" {
  description = "Boot disk image for the instance"
  type        = string
  default     = "ubuntu-os-cloud/ubuntu-2404-noble-amd64-v20250828"
}

variable "boot_disk_size" {
  description = "Boot disk size in GB"
  type        = number
  default     = 30
}

variable "boot_disk_type" {
  description = "Boot disk type"
  type        = string
  default     = "pd-standard"
}

variable "ssh_user" {
  description = "SSH username"
  type        = string
  default     = "ubuntu"
}

variable "ssh_public_key" {
  description = "SSH public key for instance access"
  type        = string
  default     = ""
}

variable "ssh_source_ranges" {
  description = "Source IP ranges for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "kubectl_source_ranges" {
  description = "Source IP ranges for kubectl access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "minikube_version" {
  description = "Minikube version to install"
  type        = string
  default     = "latest"
}

variable "kubernetes_version" {
  description = "Kubernetes version for Minikube"
  type        = string
  default     = "v1.28.3"
}

variable "minikube_driver" {
  description = "Minikube driver (docker or none)"
  type        = string
  default     = "docker"
}

variable "minikube_cpus" {
  description = "Number of CPUs for Minikube"
  type        = number
  default     = 2
}

variable "minikube_memory" {
  description = "Memory for Minikube in MB"
  type        = string
  default     = "4096"
}

variable "minikube_disk_size" {
  description = "Disk size for Minikube"
  type        = string
  default     = "20g"
}

variable "container_runtime" {
  description = "Container runtime for Minikube"
  type        = string
  default     = "docker"
}

variable "labels" {
  description = "Labels to apply to resources"
  type        = map(string)
  default = {
    environment = "dev"
    managed_by  = "terraform"
    purpose     = "ai-starter-kit"
  }
}