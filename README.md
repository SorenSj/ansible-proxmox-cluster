# Ansible-Proxmox-Cluster

This is an ansible playbook for configuring a [Proxmox](https://pve.proxmox.com) cluster (Virtual Machine Hypervisor) and [Ceph](https://ceph.com/) (distributed/clustered block storage and filesystem.)

## Features

- Configuration of Proxmox cluster
- Installation and configuration of Ceph cluster
- CPU optimization 
- WatchDog configuration
- ZFS configuration
- Keyboard and locales configuration (for non-US citizens )
- Date and timezone configuration 
- Creation of virtual machines (KVM)
- Network configuration
- User configuration
- Storage configuration
- SSH configuration
- Secure the nodes, removing password authentication



## Minimum hardware requirements 



## My setup

The included [hosts](inventory/hosts) file references 3 identically configured [Shuttle XPC nano NC40U7](https://www.shuttle.eu/en/products/nano/nc40u7) mini PCs called `pxenode1`, `pxenode2`, and `pxenode3`. Furthermore, there are 3 Intel NUCs that are part of my Proxmox cluster, but which are not part of the Ceph cluster. The 3 machines are called `pxemail` (mail server and mail scanner). `pxelog` (central log server) and `pxesearch` (OpenSearch server). Also included is a Synology NAS server with 8TB RAID. It is used for backup and storage for OS iso files.

NOTE: This is a very minimal ceph setup. Ceph should ideally use more disks and more nodes. This setup can theoretically survive if one of the nodes dies. Two of the three nodes must still be operational for your data to survive. Do your backups!

**Hardware, Shuttle XPC:**

 * 12 core i7 processor (24 vCPUs)
 * 64GB RAM
 * Single onboard 1GbE network adapter
 * Additional external USB 1GbE network adapter
 * 512MB m.2 SSD `nvme0n1` for boot device and `local-lvm` (non-distributed).
 * 2TB m.2 SSD `nvme1n1` for Ceph OSD (distributed/clustered storage).

Each node has two NICs:

 * `eno1` - The public internet route and management device. `10.0.2.0/24`
 * `enxAAAAAAAAAAAA` - A USB ethernet (Where the A's are the mac address) - used for the private ceph network. `10.10.2.0/24`.

Ceph RBD (block) storage:

 * `ceph-vm` VM block storage devices and images.
 * `ceph-ct` Container storage.

CephFS (distributed filesystem on top of RBD):

 * `cephfs` Container templates, ISO images, VZDump backup files.

The `local-lvm` is also available on each node, as a traditional file store (non-ceph, non-distributed. Do your backups! Seriously though, do your backups even for the ceph storage.)

**Hardware, Intel NUC (pxelog):**

 * 4 core i7 processor (8 vCPUs)
 * 32GB RAM
 * Single onboard 1GbE network adapter
 * 1TB m.2 SSD `nvme0n1` for boot device and `local-lvm` (non-distributed).

**Hardware, Intel NUC (pxemail):**

 * 12 core i7 processor (24 vCPUs)
 * 64GB RAM
 * Single onboard 1GbE network adapter
 * 1TB m.2 SSD `nvme0n1` for boot device and `local-lvm` (non-distributed).

**Hardware, Intel NUC (pxesearch):**

 * 8 core i7 processor (16 vCPUs)
 * 64GB RAM
 * Single onboard 1GbE network adapter
 * 1TB SATA SSD `sda` for boot device and `local-lvm` (non-distributed).
 * 256MB m.2 SSD nvme0n1 for ZFS drive (non-distributed)

The search server doesn't really use the ZFS drive for anything meaningful. It's only included to test my Ansible code.



## Initial setup

* Configure BIOS on each machine:
  * Reset BIOS to factory defaults.
  * Turn off Secure Boot.
* Boot from proxmox USB install media.
* Setup identically on each node.
* Use a different hostname and static IP address for each machine.
* Choose XFS for root filesystem.



## Configure SSH

Create an ssh config file on your development workstation (`$HOME/.ssh/config`):

```
Host pxenode1
  Hostname 10.0.2.101
  User root

Host pxenode2
  Hostname 10.0.1.102
  User root

Host pxenode3
  Hostname 10.0.2.103
  User root

Host pxelog
  Hostname 10.0.2.129
  User root

Host pxemail
  Hostname 10.0.2.126
  User root

Host pxesearch
  Hostname 10.0.2.120
  User root
```

Use the static IP addresses chosen at install time.

From your development workstation, copy your SSH key to the root user's `authorized_keys` file on each node:

```
ssh-copy-id pxenode1
ssh-copy-id pxenode2
ssh-copy-id pxenode3
ssh-copy-id pxelog
ssh-copy-id pxemail
ssh-copy-id pxesearch
```

Enter the same password as used during setup.



## Create Ansible hosts file

Edit the ansible `hosts` file for your own nodes. The included one is setup for the three Shuttle PC and the three Intel NUCs.

The various roles are:

 * `proxmox` - The group of nodes to install proxmox on. `pxenode1, pxenode2, pxenode3, pxelog, pxemail, pxesearch`.
 * `ceph` - The group of nodes to install ceph on. `pxenode1, pxenode2, pxenode3`.
 * `ceph_mon` - The group of nodes to run `ceph-mon`. `pxenode1, pxenode2, pxenode3`.
 * `ceph_mgr` - The group of nodes to run `ceph-mgr`. `pxenode1, pxenode2, pxenode3`.
 * `ceph_osd` - The group of nodes to run `ceph-osd`. `pxenode1, pxenode2, pxenode3`.
 * `ceph_mds` - The group of nodes to run `ceph-mds`. `pxenode1, pxenode2, pxenode3`.

The hostnames are matched by the `Host` variable in your ssh config file (It is not resolved via DNS, and you do not need a FQDN.)



## Create Ansible Vault (secrets)

The ansible.cfg file specifies that Ansible vault uses a password file, so you don't have to enter a password when creating or editing the vault file. Therefore, from the root of the repository, you must create the file .vault_pass:

```
nano .vault_pass
```

Then create an ansible vault to store the root proxmox password and encrypt it. 

From the root directory of this repository, run:

```
ansible-vault create inventory/group_vars/proxmox/vault.yml
```

An editor will open in which to store the unencrypted vault contents. Enter the
text and save the file:

```
vault_proxmox_password: "YOUR PROXMOX ROOT PASSPHRASE HERE"

```

Set:
 `vault_proxmox_password` - the root password you used during setup.

Now you can double-check that the vault is encrypted:

```
cat inventory/group_vars/proxmox/vault.yml
```

Which should look something like:

```
$ANSIBLE_VAULT;1.1;AES256
34393966383135653437323561663465623539393239393662343035653161366633666365643065
3965343630366433653531663364393236376330353062660a616435636530373966373962663565
30643264373362633561363437396461636466643362626331323264616462373837373263616135
3863326139653364310a356534376637326136626134303138373264346566303430663661303537
35353961663662663437643262356566636536326332666630383038346564373064393538366334
3230303065623738363064613366626234633833653164363365
```



## Configuration

Since there are many large and small things that can be configured, the most important things are specified in separate configuration files:

#### defaults.yml

This file defines various system wide variables such as domain name, timezone, keyboard layout, etc. The path to where the file is located is `inventory/group_vars/all/defaults.yml`.

#### network.yml

If you wish to change the network configuration, the file `inventory/group_vars/all/network.yml` needs to be edited.

#### users.yml

By default, a few different users and groups are created. All users and associated groups are specified in the file `users.yml`, which is located under the path `inventory/group_vars/all/users.yml`. The file also specifies ACLs (Access Control Lists) and various roles.

#### proxmox.yml

This is the largest configuration file there is. There are many important things specified here. Be careful what you change in this file. Incorrectly defined variables can in worst case cause the entire system to crash. The path to the file is `inventory/group_vars/proxmox/proxmox.yml`.

#### ceph.yml





## Run site.yml playbook

The `site.yml` playbook will do the 

 * Configuration and optimization described under features
 * Create Proxmox cluster
 * Create Ceph cluster and storage

Run the playbook:

```
ansible-playbook site.yml
```

