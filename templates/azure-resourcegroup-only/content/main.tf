module "mod_azregions" {
  source = "github.com/POps-Rox/terraform-az-overlays-azregionslookup?ref=v2.0.0"

  azure_region = "${{ values.location }}"
}

module "mod_resource_group" {
  source = "github.com/POps-Rox/terraform-az-overlays-resourcegroup?ref=v2.0.0"

  org_name      = "${{ values.org_name }}"
  environment   = "${{ values.environment }}"
  workload      = "${{ values.name }}"
  location      = module.mod_azregions.location_short

  enable_resource_locks = ${{ values.enable_resource_locks }}
  lock_level            = "${{ values.lock_level }}"

  add_tags = {
    DeployedBy  = "POps-Rox-Backstage"
    Workload    = "${{ values.name }}"
    Environment = "${{ values.environment }}"
    Org         = "${{ values.org_name }}"
  }
}

output "resource_group_name" {
  description = "Resource group name."
  value       = module.mod_resource_group.resource_group_name
}

output "resource_group_id" {
  description = "Resource group ID."
  value       = module.mod_resource_group.resource_group_id
}
