variable "proxmox_api_username" {
  description = "The Proxmox API username"
  type        = string
}

variable "proxmox_api_password" {
  description = "The Proxmox API password"
  type        = string
}

variable "proxmox_ssh_private_key" {
  description = "The private key for the Proxmox SSH connection"
  type        = string
}

variable "admin_ssh_public_key" {
  description = "The public key for the admin user"
  type        = string
}



variable "vm_img" {
  default = "https://cloud-images.ubuntu.com/releases/22.04/release/ubuntu-22.04-server-cloudimg-amd64.img"
  type    = string
}

variable "proxmox_host_ip" {
  default = "10.0.0.1"
  type    = string
}

variable "node_name" {
  default = "pve"
}

variable "utility_hostname" {
  default = "utility-node"
}


variable "RANCHER_HOSTNAME" {
  default = "k8s"
}

variable "RANCHER_DOMAIN" {
  default = "suncoast.systems"
}


variable "MONITORED_RESOURCE_TYPE" {
  default = "generic_node"
}

variable "REGION" {
  default = "us-east1"
}

variable "MONITORED_RESOURCE_NAMESPACE" {
  default = "suncoast-systems-k8s"
}

variable "GITHUB_ORG" {
  description = "GitHub organization for the cluster"
  type        = string
  default     = "suncoast-systems-k8s"
}



variable "VM_DISK_STORAGE" {
  default = "Cluster"
}

variable "UBUNTU_RELEASE_CODE_NAME" {
  default = "noble"
}


variable "project_name" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The region to use (ex. global or us-east1)"
  type        = string
}

variable "gcp_org_id" {
  description = "The organization id to create the project under"
  type        = string
  nullable = false
}

variable billing_account {
    description = "The billing account to associate with the project"
    type        = string
    nullable = false
}

variable "bucket_name" {
  description = "Name of the bucket"
  type        = string
  default = "proxmox-gcsfuse-bucket"
}

variable "retention_days" {
  description = "Number of days to retain files before auto-deletion"
  type        = number
  default     = 30
}



variable "enable_hugepages" {
  description = "Enable hugepages for VMs"
  type        = bool
  default     = true
}

variable "hugepages_value" {
  description = "Hugepages value in MiB"
  type        = number
  default     = 1024
}

