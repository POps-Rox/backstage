output "hub_virtual_network_id" {
  description = "ID of the hub virtual network."
  value       = module.mod_hubspoke.hub_virtual_network_id
}

output "hub_resource_group_name" {
  description = "Hub resource group name."
  value       = module.mod_hubspoke.hub_resource_group_name
}

output "management_hub_resource_group_name" {
  description = "Management hub resource group name."
  value       = module.mod_managementhub.resource_group_name
}

output "management_spoke_resource_group_name" {
  description = "Management spoke resource group name."
  value       = module.mod_managementspoke.resource_group_name
}

output "workload_spoke_resource_group_name" {
  description = "Workload spoke resource group name."
  value       = module.mod_workloadspoke.resource_group_name
}
