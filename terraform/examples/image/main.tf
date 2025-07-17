terraform {
  required_version = ">=1.5.0"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">=0.53.1"
    }
  }
}

provider "proxmox" {
  endpoint  = var.pve_api_url
  api_token = "${var.pve_token_id}=${var.pve_token_secret}"
  insecure  = false
  ssh {
    agent       = true
    username    = var.pve_user
    password    = var.pve_password
    private_key = var.pve_ssh_key_private
  }
}

# VM Image: Convert *.qcow2 image to *.img
module "debian12" {
  source = "github.com/sorensj/terraform-bpg-proxmox/modules/image"

  node                     = "pxenode1"
  image_filename           = "debian-12-generic-amd64.img"
  image_url                = "https://cloud.debian.org/images/cloud/bookworm/20240211-1654/debian-12-generic-amd64-20240211-1654.qcow2"
  image_checksum           = "b679398972ba45a60574d9202c4f97ea647dd3577e857407138b73b71a3c3c039804e40aac2f877f3969676b6c8a1ebdb4f2d67a4efa6301c21e349e37d43ef5"
  image_checksum_algorithm = "sha512"
}

# VM Image: Minimal configuration
module "ubuntu24" {
  source = "github.com/sorensj/terraform-bpg-proxmox/modules/image"

  node                     = "pxenode1"
  image_url                = "https://cloud-images.ubuntu.com/releases/noble/release-20250704/ubuntu-24.04-server-cloudimg-amd64.img" # Required
  image_checksum           = "f1652d29d497fb7c623433705c9fca6525d1311b11294a0f495eed55c7639d1f"                                       # Required
}

# LXC: Container images are updated daily, set DATE and SHASUM values!
module "lxc_ubuntu24" {
  source = "github.com/sorensj/terraform-bpg-proxmox/modules/image"

  node               = "pxenode1"
  image_filename     = "ubuntu-24.04-cloudimg-amd64-20250715.tar.xz"
  image_url          = "https://images.linuxcontainers.org/images/ubuntu/noble/amd64/cloud/20250715_07%3A42/rootfs.tar.xz"
  image_checksum     = "8c4388406159c2f377d011a64a799ac87c7c083ab4a1f552eb62ac2aa2960ca9"
  image_content_type = "vztmpl"
}
