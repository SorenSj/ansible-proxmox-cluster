
resource "proxmox_vm_qemu" "k8s_master1" {
  name        = "k8s_master1"
  target_node = "pve"
  clone       = "ubuntu-24.04.01"
  desc        = "Master Node 1"
  onboot = true
  full_clone = true
  agent      = 1
  cores      = 2
  sockets    = 1
  cpu        = "host"
  memory     = 4096
  scsihw     = "virtio-scsi-pci"
  os_type    = "ubuntu"
  qemu_os    = "126"

  network {
    bridge = "vmbr0"
    model  = "virtio"
  }
  disks {
    scsi {
      scsi0 {
        disk {
          storage = "disk_images"
          # size cannot be less than the image template (25G)
          size = 32
        }
      }
    }
  }

  pool = "VMPool"

  connection {
    type     = "ssh"
    user     = "root"
    password = var.ssh_pass
    host     = self.default_ipv4_address
  }

  # setup network custom information
  provisioner "file" {
    source = "./m1-netplan.yaml"
    destination = "/tmp/00-netplan.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "echo root | sudo -S mv /tmp/00-netplan.yaml /etc/netplan/00-netplan.yaml",
      "sudo hostnamectl set-hostname k8s_master1",
      "sudo netplan apply && sudo ip addr add dev eno1 ${self.default_ipv4_address}",
      "ip a s"
     ] 
  }
}

resource "proxmox_vm_qemu" "k8s_master2" {
  name        = "k8s_master2"
  target_node = "pve"
  clone       = "ubuntu-24.04.01"
  desc        = "Master Node 2"
  onboot = true
  full_clone = true
  agent      = 1
  cores      = 2
  sockets    = 1
  cpu        = "host"
  memory     = 4096
  scsihw     = "virtio-scsi-pci"
  os_type    = "ubuntu"
  qemu_os    = "126"

  network {
    bridge = "vmbr0"
    model  = "virtio"
  }
  disks {
    scsi {
      scsi0 {
        disk {
          storage = "disk_images"
          # size cannot be less than the image template (25G)
          size = 32
        }
      }
    }
  }

  pool = "VMPool"

  connection {
    type     = "ssh"
    user     = "root"
    password = var.ssh_pass
    host     = self.default_ipv4_address
  }

  # setup network custom information
  provisioner "file" {
    source = "./m2-netplan.yaml"
    destination = "/tmp/00-netplan.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "echo root | sudo -S mv /tmp/00-netplan.yaml /etc/netplan/00-netplan.yaml",
      "sudo hostnamectl set-hostname k8s_master2",
      "sudo netplan apply && sudo ip addr add dev eno1 ${self.default_ipv4_address}",
      "ip a s"
     ] 
  }
}

resource "proxmox_vm_qemu" "k8s_master3" {
  name        = "k8s_master3"
  target_node = "pve"
  clone       = "ubuntu-24.04.01"
  desc        = "Master Node 3"
  onboot = true
  full_clone = true
  agent      = 1
  cores      = 2
  sockets    = 1
  cpu        = "host"
  memory     = 4096
  scsihw     = "virtio-scsi-pci"
  os_type    = "ubuntu"
  qemu_os    = "126"

  network {
    bridge = "vmbr0"
    model  = "virtio"
  }
  disks {
    scsi {
      scsi0 {
        disk {
          storage = "disk_images"
          # size cannot be less than the image template (25G)
          size = 32
        }
      }
    }
  }

  pool = "VMPool"

  connection {
    type     = "ssh"
    user     = "root"
    password = var.ssh_pass
    host     = self.default_ipv4_address
  }

  # setup network custom information
  provisioner "file" {
    source = "./m3-netplan.yaml"
    destination = "/tmp/00-netplan.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "echo root | sudo -S mv /tmp/00-netplan.yaml /etc/netplan/00-netplan.yaml",
      "sudo hostnamectl set-hostname k8s_master3",
      "sudo netplan apply && sudo ip addr add dev eno1 ${self.default_ipv4_address}",
      "ip a s"
     ] 
  }
}

resource "proxmox_vm_qemu" "k8s_worker1" {
  name        = "k8s_worker1"
  target_node = "pve"
  clone       = "ubuntu-24.04.01"
  desc        = "Worker Node 1"
  onboot = true
  full_clone = true
  agent      = 1
  cores      = 4
  sockets    = 1
  cpu        = "host"
  memory     = 8192
  scsihw     = "virtio-scsi-pci"
  os_type    = "ubuntu"
  qemu_os    = "126"

  network {
    bridge = "vmbr6"
    model  = "virtio"
  }
  disks {
    scsi {
      scsi0 {
        disk {
          storage = "disk_images"
          # size cannot be less than the image template (25G)
          size = 32
        }
      }
    }
  }

  pool = "VMPool"

  connection {
    type     = "ssh"
    user     = "root"
    password = var.ssh_pass
    host     = self.default_ipv4_address
  }

  # setup network custom information
  provisioner "file" {
    source = "./w1-netplan.yaml"
    destination = "/tmp/00-netplan.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "echo root | sudo -S mv /tmp/00-netplan.yaml /etc/netplan/00-netplan.yaml",
      "sudo hostnamectl set-hostname k8s_worker1",
      "sudo netplan apply && sudo ip addr add dev eno1 ${self.default_ipv4_address}",
      "ip a s"
     ] 
  }

}

resource "proxmox_vm_qemu" "k8s_worker2" {
  name        = "k8s_worker2"
  target_node = "pve"
  clone       = "ubuntu-24.04.01"
  desc        = "Worker Node 2"
  onboot = true
  full_clone = true
  agent      = 1
  cores      = 4
  sockets    = 1
  cpu        = "host"
  memory     = 8192
  scsihw     = "virtio-scsi-pci"
  os_type    = "ubuntu"
  qemu_os    = "126"

  network {
    bridge = "vmbr0"
    model  = "virtio"
  }
  disks {
    scsi {
      scsi0 {
        disk {
          storage = "disk_images"
          # size cannot be less than the image template (25G)
          size = 32
        }
      }
    }
  }

  pool = "VMPool"

  connection {
    type     = "ssh"
    user     = "root"
    password = var.ssh_pass
    host     = self.default_ipv4_address
  }

  # setup network custom information
  provisioner "file" {
    source = "./w2-netplan.yaml"
    destination = "/tmp/00-netplan.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "echo root | sudo -S mv /tmp/00-netplan.yaml /etc/netplan/00-netplan.yaml",
      "sudo hostnamectl set-hostname k8s_worker2",
      "sudo netplan apply && sudo ip addr add dev eno1 ${self.default_ipv4_address}",
      "ip a s"
     ] 
  }
}

resource "proxmox_vm_qemu" "k8s_worker3" {
  name        = "k8s_worker3"
  target_node = "pve"
  clone       = "ubuntu-24.04.01"
  desc        = "Worker Node 3"
  onboot = true
  full_clone = true
  agent      = 1
  cores      = 4
  sockets    = 1
  cpu        = "host"
  memory     = 8192
  scsihw     = "virtio-scsi-pci"
  os_type    = "ubuntu"
  qemu_os    = "126"

  network {
    bridge = "vmbr0"
    model  = "virtio"
  }
  disks {
    scsi {
      scsi0 {
        disk {
          storage = "disk_images"
          # size cannot be less than the image template (25G)
          size = 32
        }
      }
    }
  }

  pool = "VMPool"

  connection {
    type     = "ssh"
    user     = "root"
    password = var.ssh_pass
    host     = self.default_ipv4_address
  }

  # setup network custom information
  provisioner "file" {
    source = "./w3-netplan.yaml"
    destination = "/tmp/00-netplan.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "echo root | sudo -S mv /tmp/00-netplan.yaml /etc/netplan/00-netplan.yaml",
      "sudo hostnamectl set-hostname k8s_worker3",
      "sudo netplan apply && sudo ip addr add dev eno1 ${self.default_ipv4_address}",
      "ip a s"
     ] 
  }
}
