# General
variable "project_id" {
  type = string
}

# google_service_account
variable "sa_account_id" {
  type = string
}

variable "sa_display_name" {
  type    = string
  default = "Custom SA for VM Instance"
}

# google_compute_instance
variable "vm_name" {
  type = string
}

variable "vm_machine_type" {
  type = string
  default = "n2-standard-2"
}

variable "vm_zone" {
  type = string
  default = "us-central1-a"
}

variable "vm_image" {
  type = string
  default = "debian-cloud/debian-11"
}
