output "azure_region_short" {
  description = "Short-form Azure region name used by the overlays (e.g., eus)."
  value       = module.mod_azregions.location_short
}

{%- if 'resourcegroup' in values.modules %}

output "resource_group_name" {
  description = "Name of the workload resource group."
  value       = module.mod_resource_group.resource_group_name
}

output "resource_group_id" {
  description = "ID of the workload resource group."
  value       = module.mod_resource_group.resource_group_id
}
{%- endif %}
{%- if 'storageaccount' in values.modules %}

output "storage_account_name" {
  description = "Name of the workload storage account."
  value       = module.mod_storage.storage_account_name
}
{%- endif %}
{%- if 'keyvault' in values.modules %}

output "key_vault_name" {
  description = "Name of the workload key vault."
  value       = module.mod_keyvault.key_vault_name
}

output "key_vault_uri" {
  description = "URI of the workload key vault."
  value       = module.mod_keyvault.key_vault_uri
}
{%- endif %}
{%- if 'containerregistry' in values.modules %}

output "container_registry_name" {
  description = "Name of the container registry."
  value       = module.mod_acr.container_registry_name
}
{%- endif %}
{%- if 'kubernetes' in values.modules %}

output "aks_cluster_name" {
  description = "Name of the AKS cluster."
  value       = module.mod_aks.aks_cluster_name
}
{%- endif %}
