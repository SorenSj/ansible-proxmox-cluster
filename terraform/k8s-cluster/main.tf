
resource "null_resource" "cloud_init" {
  connection {
    host        = var.pve_host_address
    port        = var.pve_host_port
    user        = var.pve_user
    password    = var.pve_password
    private_key = file(var.pve_ssh_key_private)
  }

  provisioner "file" {
    content     = file("${path.module}/files/vendor-data.yaml")
    destination = "/var/lib/vz/snippets/vendor-data.yaml"
  }
}

module "k8s_cluster_node1" {
  depends_on = [null_resource.cloud_init]
  source     = "github.com/sorensj/terraform-bpg-proxmox/modules/vm-clone"

  for_each = tomap({
    "k8s-master1" = {
      id           = 231
      ipv4_cidr    = "10.0.2.31/24"
      ipv4_gateway = "10.0.2.1"
      vcpu         = 2
      memory       = 4096
      disk_size    = 32
    },
    "k8s-worker1" = {
      id           = 232
      ipv4_cidr    = "10.0.2.32/24"
      ipv4_gateway = "10.0.2.1"
      vcpu         = 4
      memory       = 8192
      disk_size    = 64
    },
  })

  node            = "pxenode1"                        # required
  vm_id           = each.value.id                     # required
  vm_name         = each.key                          # optional
  template_id     = 9000                              # required
  vcpu            = each.value.vcpu                   # optional
  memory          = each.value.memory                 # optional
  disks = [
    {
      disk_interface = "scsi0", # default cloud image boot drive
      disk_size      = each.value.disk_size,
    },
  ]
  bios            = var.pve_bios                      # optional
  ci_ssh_key      = "~/.ssh/id_ed25519.pub"           # optional, add SSH key to "default" user
  ci_ipv4_cidr    = each.value.ipv4_cidr              # optional
  ci_ipv4_gateway = each.value.ipv4_gateway           # optional
  ci_vendor_data  = "local:snippets/vendor-data.yaml" # optional
}

module "k8s_cluster_node2" {
  depends_on = [null_resource.cloud_init]
  source     = "github.com/sorensj/terraform-bpg-proxmox/modules/vm-clone"

  for_each = tomap({
    "k8s-master2" = {
      id           = 241
      ipv4_cidr    = "10.0.2.41/24"
      ipv4_gateway = "10.0.2.1"
      vcpu         = 2
      memory       = 4096
      disk_size    = 32
    },
    "k8s-worker2" = {
      id           = 242
      ipv4_cidr    = "10.0.2.42/24"
      ipv4_gateway = "10.0.2.1"
      vcpu         = 4
      memory       = 8192
      disk_size    = 64
    },
  })

  node            = "pxenode2"                        # required
  vm_id           = each.value.id                     # required
  vm_name         = each.key                          # optional
  template_id     = 9001                              # required
  vcpu            = each.value.vcpu                   # optional
  memory          = each.value.memory                 # optional
  disks = [
    {
      disk_interface = "scsi0", # default cloud image boot drive
      disk_size      = each.value.disk_size,
    },
  ]
  bios            = var.pve_bios                      # optional
  ci_ssh_key      = "~/.ssh/id_ed25519.pub"           # optional, add SSH key to "default" user
  ci_ipv4_cidr    = each.value.ipv4_cidr              # optional
  ci_ipv4_gateway = each.value.ipv4_gateway           # optional
  ci_vendor_data  = "local:snippets/vendor-data.yaml" # optional
}

module "k8s_cluster_node3" {
  depends_on = [null_resource.cloud_init]
  source     = "github.com/sorensj/terraform-bpg-proxmox/modules/vm-clone"

  for_each = tomap({
    "k8s-master3" = {
      id           = 251
      ipv4_cidr    = "10.0.2.51/24"
      ipv4_gateway = "10.0.2.1"
      vcpu         = 2
      memory       = 4096
      disk_size    = 32
    },
    "k8s-worker3" = {
      id           = 252
      ipv4_cidr    = "10.0.2.52/24"
      ipv4_gateway = "10.0.2.1"
      vcpu         = 4
      memory       = 8192
      disk_size    = 64
    },
  })

  node            = "pxenode3"                        # required
  vm_id           = each.value.id                     # required
  vm_name         = each.key                          # optional
  template_id     = 9002                              # required
  vcpu            = each.value.vcpu                   # optional
  memory          = each.value.memory                 # optional
  disks = [
    {
      disk_interface = "scsi0", # default cloud image boot drive
      disk_size      = each.value.disk_size,
    },
  ]
  bios            = var.pve_bios                      # optional
  ci_ssh_key      = "~/.ssh/id_ed25519.pub"           # optional, add SSH key to "default" user
  ci_ipv4_cidr    = each.value.ipv4_cidr              # optional
  ci_ipv4_gateway = each.value.ipv4_gateway           # optional
  ci_vendor_data  = "local:snippets/vendor-data.yaml" # optional
}

locals {
  controller_ip = module.k8s_cluster_node1["k8s-master1"].public_ipv4[0]
  agent_ips     = { for k, v in module.k8s_cluster_node1 : k => v.public_ipv4[0] if k != "k8s-master1" }
}

output "id" {
  value = { for k, v in module.k8s_cluster_node1 : k => v.id }
}

output "public_ipv4" {
  value = { for k, v in module.k8s_cluster_node1 : k => v.public_ipv4[0] }
}

output "controller_node_ip" {
  value = local.controller_ip
}

output "agent_node_ips" {
  value = local.agent_ips
}

resource "random_string" "k8s_token" {
  length  = 64
  special = false
}

resource "random_password" "k8s_password" {
  length  = 16
  special = false
  upper   = true
  lower   = true
  numeric = true
}
