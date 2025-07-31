variable "utility_cpu_cores" {
  type    = number
  default = 2
}

variable "utility_cpu_sockets" {
  type    = number
  default = 1
}

# Upload cloud-init configuration to Proxmox as a snippet
resource "proxmox_virtual_environment_file" "utility_cloud_init_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.node_name
  overwrite = false

  source_raw {
    # path = local_file.ctrl_processed_cloud_init.filename
    data  = templatefile("${path.module}/config/cloud_init_utility_vm.tftpl", {
        hostname   = var.utility_hostname
        GCP_LOGGING_KEY = local.utility_credentials_json
        ssh_keys = join("\n      - ", [trimspace(var.admin_ssh_public_key)])
        UBUNTU_RELEASE_CODE_NAME = var.UBUNTU_RELEASE_CODE_NAME
        MONITORED_RESOURCE_TYPE = var.MONITORED_RESOURCE_TYPE
        MONITORED_RESOURCE_LOCATION = var.REGION
        MONITORED_RESOURCE_NAMESPACE = var.MONITORED_RESOURCE_NAMESPACE
        MONITORED_RESOURCE_NODE_ID = var.utility_hostname
        HARBOR_VERSION = var.HARBOR_VERSION
        HARBOR_USER = var.HARBOR_USER
        HARBOR_PASS = var.HARBOR_PASS
      })
    file_name = "cloud_init_utility_vm.yaml"
  }
}

# Define the Proxmox Virtual Machine using BGP Proxmox Provider
resource "proxmox_virtual_environment_vm" "utility_vm" {
  name      = var.utility_hostname
  node_name = var.node_name
  stop_on_destroy = false
  on_boot = true

  bios     = "ovmf"  # ✅ Required for q35
  machine  = "q35"   # ✅ Enables PCIe support

  efi_disk {
    datastore_id = var.VM_DISK_STORAGE
    file_format  = "raw"
  }

  cpu {
    cores   = var.utility_cpu_cores
    sockets = var.utility_cpu_sockets
    type    = "host"       # ✅ Use host CPU for full feature set
    numa    = true         # ✅ Enable NUMA for multi-socket configs
  }

  numa {
    device     = "numa0"
    cpus       = "0-1"
    memory     = 8192  # 8 GiB
    hostnodes  = "3"
    policy     = "bind"
  }

  memory {
    dedicated = 8192       # fixed RAM allocation in MiB
    hugepages = var.enable_hugepages ? var.hugepages_value : null
  }

  agent {
    enabled = true
  }

  disk {
    datastore_id = var.VM_DISK_STORAGE
    file_id      = "local:iso/${basename(var.vm_img)}"
    interface    = "scsi0"           # ✅ Use SCSI for iothread support
    iothread     = true              # ✅ Improve I/O parallelism
    discard      = "on"
    size         = 100
    file_format  = "raw"             # ✅ Best raw performance
    cache     = "unsafe"
  }

  scsi_hardware = "virtio-scsi-single"  # ✅ Enable for efficient single queue

  boot_order = ["scsi0"]

  network_device {
    bridge   = "vmbr1"
    model    = "virtio"          # ✅ Fastest virtual NIC
    firewall = false             # ✅ Skip Proxmox firewall for performance
    queues   = var.utility_cpu_cores * var.utility_cpu_sockets   # match the number of vCPUs you assigned, e.g. 10
    mtu      = 9000                    # if your internal network supports jumbo frames
  }

  initialization {
    datastore_id = "local"
    interface    = "scsi1"
    ip_config {
      ipv4 {
        address = "10.0.0.200/24"
        gateway = "10.0.0.10"
      }
    }
    dns {
      servers = ["10.0.0.10", "8.8.8.8"]
      domain  = "internal.lan"
    }

    user_data_file_id = proxmox_virtual_environment_file.utility_cloud_init_config.id
  }

  # Make sure all other resources are completed first before building the VM's.  Rancher K8S is dependant on everything happening before it installs.
  depends_on = [ 
    null_resource.download_iso
  ]
}
