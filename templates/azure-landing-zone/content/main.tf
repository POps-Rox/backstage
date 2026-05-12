locals {
  common_tags = merge(var.add_tags, {
    DeployedBy  = "POps-Rox-Backstage"
    Enclave     = var.enclave_name
    Environment = var.deploy_environment
    Org         = var.org_name
  })
}

#############################################
# Region lookup                             #
#############################################
module "mod_azregions" {
  source = "github.com/POps-Rox/terraform-az-overlays-azregionslookup?ref=v2.0.0"

  azure_region = var.location
}

#############################################
# Hub-and-Spoke shared networking           #
#############################################
module "mod_hubspoke" {
  source = "github.com/POps-Rox/terraform-az-overlays-hubspoke?ref=v2.0.0"

  providers = {
    azurerm = azurerm
  }

  location           = var.location
  environment        = var.azure_environment
  metadata_host      = var.metadata_host
  deploy_environment = var.deploy_environment
  workload_name      = var.enclave_name
  org_name           = var.org_name

  add_tags = local.common_tags
}

#############################################
# Management hub (identity / shared svcs)   #
#############################################
module "mod_managementhub" {
  source = "github.com/POps-Rox/terraform-az-overlays-managementhub?ref=v2.0.0"

  providers = {
    azurerm = azurerm.identity
  }

  location           = var.location
  environment        = var.azure_environment
  metadata_host      = var.metadata_host
  deploy_environment = var.deploy_environment
  workload_name      = "${var.enclave_name}-mgmt-hub"
  org_name           = var.org_name

  hub_virtual_network_id = module.mod_hubspoke.hub_virtual_network_id

  add_tags = local.common_tags
}

#############################################
# Management spoke (operations / logging)   #
#############################################
module "mod_managementspoke" {
  source = "github.com/POps-Rox/terraform-az-overlays-managementspoke?ref=v2.0.0"

  providers = {
    azurerm = azurerm.operations
  }

  location           = var.location
  environment        = var.azure_environment
  metadata_host      = var.metadata_host
  deploy_environment = var.deploy_environment
  workload_name      = "${var.enclave_name}-mgmt-spoke"
  org_name           = var.org_name

  hub_virtual_network_id = module.mod_hubspoke.hub_virtual_network_id

  add_tags = local.common_tags
}

#############################################
# Initial Workload spoke                    #
#############################################
module "mod_workloadspoke" {
  source = "github.com/POps-Rox/terraform-az-overlays-workloadspoke?ref=v2.0.0"

  providers = {
    azurerm = azurerm.workload
  }

  location           = var.location
  environment        = var.azure_environment
  metadata_host      = var.metadata_host
  deploy_environment = var.deploy_environment
  workload_name      = "${var.enclave_name}-workload"
  org_name           = var.org_name

  hub_virtual_network_id = module.mod_hubspoke.hub_virtual_network_id

  add_tags = local.common_tags
}
