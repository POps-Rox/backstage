variable "enclave_name" {
  description = "kebab-case enclave name used for resource naming."
  type        = string
  default     = "${{ values.enclave_name }}"
}

variable "org_name" {
  description = "POps-Rox short organization prefix."
  type        = string
  default     = "${{ values.org_name }}"
}

variable "deploy_environment" {
  description = "Deployment environment (dev/test/prod)."
  type        = string
  default     = "${{ values.environment }}"
}

variable "azure_environment" {
  description = "Azure cloud environment (public, usgovernment)."
  type        = string
  default     = "${{ values.azure_environment }}"
}

variable "location" {
  description = "Primary Azure region."
  type        = string
  default     = "${{ values.location }}"
}

variable "metadata_host" {
  description = "Azure metadata host."
  type        = string
  default     = "${{ values.azure_environment }}" == "usgovernment" ? "management.usgovcloudapi.net" : "management.azure.com"
}

variable "parent_management_group_id" {
  description = "Parent management group that anchors the enclave hierarchy."
  type        = string
  default     = "${{ values.parent_management_group_id }}"
}

variable "hub_subscription_id" {
  description = "Subscription hosting the hub network and shared services."
  type        = string
  default     = "${{ values.hub_subscription_id }}"
}

variable "identity_subscription_id" {
  description = "Subscription hosting identity / management-hub workloads."
  type        = string
  default     = "${{ values.identity_subscription_id }}"
}

variable "operations_subscription_id" {
  description = "Subscription hosting operations / management-spoke workloads."
  type        = string
  default     = "${{ values.operations_subscription_id }}"
}

variable "workload_subscription_id" {
  description = "Subscription hosting the initial workload spoke."
  type        = string
  default     = "${{ values.workload_subscription_id }}"
}

variable "add_tags" {
  description = "Common tags applied across every overlay."
  type        = map(string)
  default     = {}
}
