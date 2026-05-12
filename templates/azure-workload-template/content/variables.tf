variable "location" {
  description = "Azure region in which the workload will be hosted."
  type        = string
  default     = "${{ values.location }}"
}

variable "deploy_environment" {
  description = "Name of the workload's environment (dev, test, prod)."
  type        = string
  default     = "${{ values.environment }}"
}

variable "workload_name" {
  description = "Name of the workload."
  type        = string
  default     = "${{ values.name }}"
}

variable "org_name" {
  description = "POps-Rox short organization prefix."
  type        = string
  default     = "${{ values.org_name }}"
}

variable "environment" {
  description = "Terraform / Azure cloud environment (public, usgovernment)."
  type        = string
  default     = "public"
}

variable "metadata_host" {
  description = "Azure metadata host (management.azure.com / management.usgovcloudapi.net)."
  type        = string
  default     = "management.azure.com"
}

variable "add_tags" {
  description = "Map of tags applied to every resource."
  type        = map(string)
  default     = {}
}
