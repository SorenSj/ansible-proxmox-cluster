#!/bin/bash
# ssh-copy-id-all.sh
# This script copies the SSH public key to all hosts defined in the Ansible inventory file.

# Get the list of hosts from the Ansible inventory file
if ! command -v ansible-inventory >/dev/null 2>&1 || ! command -v jq >/dev/null 2>&1; then
  echo "Error: ansible-inventory and jq must be installed."
  exit 1
fi

hosts=$(ansible-inventory --list | jq -r '[paths(scalars) as $p | if ($p[-2] == "hosts") then getpath($p) else empty end]|flatten|unique|.[]')

if [ -z "$hosts" ]; then
  echo "No hosts found in inventory."
  exit 1
fi
# Add domain to hostnames in a loop
hostnames=""
for i in $hosts; do
  hostnames="$hostnames $i.dmz.mylabnet.tech"
done
hosts="$hostnames"

# Convert hostnames to IP addresses
ips=""
for host in $hosts; do
  ip=$(getent hosts "$host" | awk '{ print $1 }')
  if [ -n "$ip" ]; then
    ips="$ips $ip"
  else
    echo "Warning: Could not resolve $host to IP address."
  fi
done

# Use IPs instead of hostnames for further operations
hosts="$ips"
# Remove all hosts from known_hosts
for host in $hosts; do
  ssh-keygen -R $host
done
# Loop through each host and copy the SSH public key
for host in $hosts; do
  ssh-copy-id -i ~/.ssh/id_rsa.pub ubuntu@$host
done

# Check if the SSH key was copied successfully
if [ $? -eq 0 ]; then
  echo "SSH public key copied to all hosts successfully."
else
  echo "Failed to copy SSH public key to some hosts."
  exit 1
fi
# End of script