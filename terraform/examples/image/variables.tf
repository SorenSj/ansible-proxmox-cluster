## Provider Login Variables
variable "pve_token_id" {
  description = "Proxmox API Token Name."
  sensitive   = true
}

variable "pve_token_secret" {
  description = "Proxmox API Token Value."
  sensitive   = true
}

variable "pve_api_url" {
  description = "Proxmox API Endpoint, e.g. 'https://pve.example.com/api2/json'"
  type        = string
  sensitive   = true
  validation {
    condition     = can(regex("(?i)^http[s]?://.*/api2/json$", var.pve_api_url))
    error_message = "Proxmox API Endpoint Invalid. Check URL - Scheme and Path required."
  }
}

## Proxmox SSH Variables
variable "pve_user" {
  description = "Proxmox username"
  type        = string
  sensitive   = true
}

variable "pve_password" {
  description = "Proxmox password for SSH"
  type        = string
  sensitive   = true
  default     = null
}

variable "pve_ssh_key_private" {
  description = "File path to private SSH key for PVE - overrides 'pve_password'"
  type        = string
  sensitive   = true
  default     = null
}