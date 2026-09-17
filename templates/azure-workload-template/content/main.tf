# Azure Region lookup — produces both the CLI-form (eastus) and short-form (eus)
# of the requested region, used by overlay naming conventions.
module "mod_azregions" {
  source = "github.com/POps-Rox/terraform-az-overlays-azregionslookup?ref=v2.0.0"

  azure_region = var.location
}

locals {
  common_tags = merge(var.add_tags, {
    DeployedBy  = "POps-Rox-Backstage"
    Workload    = var.workload_name
    Environment = var.deploy_environment
    Org         = var.org_name
  })
}

{%- if 'resourcegroup' in values.modules %}

#################################
# Resource Group                #
#################################
module "mod_resource_group" {
  source = "github.com/POps-Rox/terraform-az-overlays-resourcegroup?ref=v2.0.0"

  org_name      = var.org_name
  environment   = var.deploy_environment
  workload      = var.workload_name
  location      = module.mod_azregions.location_short

  add_tags = local.common_tags
}
{%- endif %}
{%- if 'storageaccount' in values.modules %}

#################################
# Storage Account               #
#################################
module "mod_storage" {
  source = "github.com/POps-Rox/terraform-az-overlays-storageaccount?ref=v2.0.0"

  location           = var.location
  environment        = var.environment
  deploy_environment = var.deploy_environment
  workload_name      = var.workload_name
  org_name           = var.org_name
  metadata_host      = var.metadata_host

  {%- if 'resourcegroup' in values.modules %}
  existing_resource_group_name = module.mod_resource_group.resource_group_name
  create_resource_group        = false
  {%- endif %}

  add_tags = local.common_tags
}
{%- endif %}
{%- if 'keyvault' in values.modules %}

#################################
# Key Vault                     #
#################################
module "mod_keyvault" {
  source = "github.com/POps-Rox/terraform-az-overlays-keyvault?ref=v2.0.0"

  location           = var.location
  environment        = var.environment
  deploy_environment = var.deploy_environment
  workload_name      = var.workload_name
  org_name           = var.org_name
  metadata_host      = var.metadata_host

  {%- if 'resourcegroup' in values.modules %}
  existing_resource_group_name = module.mod_resource_group.resource_group_name
  create_resource_group        = false
  {%- endif %}

  add_tags = local.common_tags
}
{%- endif %}
{%- if 'containerregistry' in values.modules %}

#################################
# Container Registry            #
#################################
module "mod_acr" {
  source = "github.com/POps-Rox/terraform-az-overlays-containerregistry?ref=v2.0.0"

  location           = var.location
  environment        = var.environment
  deploy_environment = var.deploy_environment
  workload_name      = var.workload_name
  org_name           = var.org_name
  metadata_host      = var.metadata_host

  {%- if 'resourcegroup' in values.modules %}
  existing_resource_group_name = module.mod_resource_group.resource_group_name
  create_resource_group        = false
  {%- endif %}

  add_tags = local.common_tags
}
{%- endif %}
{%- if 'kubernetes' in values.modules %}

#################################
# AKS Cluster                   #
#################################
module "mod_aks" {
  source = "github.com/POps-Rox/terraform-az-overlays-kubernetes?ref=v2.0.0"

  location           = var.location
  environment        = var.environment
  deploy_environment = var.deploy_environment
  workload_name      = var.workload_name
  org_name           = var.org_name
  metadata_host      = var.metadata_host

  {%- if 'resourcegroup' in values.modules %}
  existing_resource_group_name = module.mod_resource_group.resource_group_name
  create_resource_group        = false
  {%- endif %}

  add_tags = local.common_tags
}
{%- endif %}
{%- if 'appservice' in values.modules %}

#################################
# App Service                   #
#################################
module "mod_appservice" {
  source = "github.com/POps-Rox/terraform-az-overlays-appservice?ref=v2.0.0"

  location           = var.location
  environment        = var.environment
  deploy_environment = var.deploy_environment
  workload_name      = var.workload_name
  org_name           = var.org_name
  metadata_host      = var.metadata_host

  {%- if 'resourcegroup' in values.modules %}
  existing_resource_group_name = module.mod_resource_group.resource_group_name
  create_resource_group        = false
  {%- endif %}

  add_tags = local.common_tags
}
{%- endif %}
{%- if 'redis' in values.modules %}

#################################
# Azure Cache for Redis         #
#################################
module "mod_redis" {
  source = "github.com/POps-Rox/terraform-az-overlays-redis?ref=v2.0.0"

  location           = var.location
  environment        = var.environment
  deploy_environment = var.deploy_environment
  workload_name      = var.workload_name
  org_name           = var.org_name
  metadata_host      = var.metadata_host

  {%- if 'resourcegroup' in values.modules %}
  existing_resource_group_name = module.mod_resource_group.resource_group_name
  create_resource_group        = false
  {%- endif %}

  add_tags = local.common_tags
}
{%- endif %}
{%- if 'cosmosdb' in values.modules %}

#################################
# Cosmos DB                     #
#################################
module "mod_cosmos" {
  source = "github.com/POps-Rox/terraform-az-overlays-cosmosdb?ref=v2.0.0"

  location           = var.location
  environment        = var.environment
  deploy_environment = var.deploy_environment
  workload_name      = var.workload_name
  org_name           = var.org_name
  metadata_host      = var.metadata_host

  {%- if 'resourcegroup' in values.modules %}
  existing_resource_group_name = module.mod_resource_group.resource_group_name
  create_resource_group        = false
  {%- endif %}

  add_tags = local.common_tags
}
{%- endif %}
{%- if 'azsql' in values.modules %}

#################################
# Azure SQL                     #
#################################
module "mod_azsql" {
  source = "github.com/POps-Rox/terraform-az-overlays-azsql?ref=v2.0.0"

  location           = var.location
  environment        = var.environment
  deploy_environment = var.deploy_environment
  workload_name      = var.workload_name
  org_name           = var.org_name
  metadata_host      = var.metadata_host

  {%- if 'resourcegroup' in values.modules %}
  existing_resource_group_name = module.mod_resource_group.resource_group_name
  create_resource_group        = false
  {%- endif %}

  add_tags = local.common_tags
}
{%- endif %}
{%- if 'apimanagement' in values.modules %}

module "mod_apim" {
  source = "github.com/POps-Rox/terraform-az-overlays-apimanagement?ref=v2.0.0"

  location           = var.location
  environment        = var.environment
  deploy_environment = var.deploy_environment
  workload_name      = var.workload_name
  org_name           = var.org_name
  metadata_host      = var.metadata_host

  {%- if 'resourcegroup' in values.modules %}
  existing_resource_group_name = module.mod_resource_group.resource_group_name
  create_resource_group        = false
  {%- endif %}

  add_tags = local.common_tags
}
{%- endif %}
{%- if 'appconfiguration' in values.modules %}

module "mod_appconfig" {
  source = "github.com/POps-Rox/terraform-az-overlays-appconfiguration?ref=v2.0.0"

  location           = var.location
  environment        = var.environment
  deploy_environment = var.deploy_environment
  workload_name      = var.workload_name
  org_name           = var.org_name
  metadata_host      = var.metadata_host

  {%- if 'resourcegroup' in values.modules %}
  existing_resource_group_name = module.mod_resource_group.resource_group_name
  create_resource_group        = false
  {%- endif %}

  add_tags = local.common_tags
}
{%- endif %}
{%- if 'openaicognitiveaccount' in values.modules %}

module "mod_openai" {
  source = "github.com/POps-Rox/terraform-az-overlays-openaicognitiveaccount?ref=v2.0.0"

  location           = var.location
  environment        = var.environment
  deploy_environment = var.deploy_environment
  workload_name      = var.workload_name
  org_name           = var.org_name
  metadata_host      = var.metadata_host

  {%- if 'resourcegroup' in values.modules %}
  existing_resource_group_name = module.mod_resource_group.resource_group_name
  create_resource_group        = false
  {%- endif %}

  add_tags = local.common_tags
}
{%- endif %}
{%- if 'containerinstance' in values.modules %}

module "mod_containerinstance" {
  source = "github.com/POps-Rox/terraform-az-overlays-containerinstance?ref=v2.0.0"

  location           = var.location
  environment        = var.environment
  deploy_environment = var.deploy_environment
  workload_name      = var.workload_name
  org_name           = var.org_name
  metadata_host      = var.metadata_host

  {%- if 'resourcegroup' in values.modules %}
  existing_resource_group_name = module.mod_resource_group.resource_group_name
  create_resource_group        = false
  {%- endif %}

  add_tags = local.common_tags
}
{%- endif %}
{%- if 'datafactory' in values.modules %}

module "mod_datafactory" {
  source = "github.com/POps-Rox/terraform-az-overlays-datafactory?ref=v2.0.0"

  location           = var.location
  environment        = var.environment
  deploy_environment = var.deploy_environment
  workload_name      = var.workload_name
  org_name           = var.org_name
  metadata_host      = var.metadata_host

  {%- if 'resourcegroup' in values.modules %}
  existing_resource_group_name = module.mod_resource_group.resource_group_name
  create_resource_group        = false
  {%- endif %}

  add_tags = local.common_tags
}
{%- endif %}
{%- if 'privatednszone' in values.modules %}

module "mod_privatedns" {
  source = "github.com/POps-Rox/terraform-az-overlays-privatednszone?ref=v2.0.0"

  location           = var.location
  environment        = var.environment
  deploy_environment = var.deploy_environment
  workload_name      = var.workload_name
  org_name           = var.org_name
  metadata_host      = var.metadata_host

  {%- if 'resourcegroup' in values.modules %}
  existing_resource_group_name = module.mod_resource_group.resource_group_name
  create_resource_group        = false
  {%- endif %}

  add_tags = local.common_tags
}
{%- endif %}
{%- if 'hubspoke' in values.modules %}

#################################
# Hub-and-Spoke Networking      #
#################################
module "mod_hubspoke" {
  source = "github.com/POps-Rox/terraform-az-overlays-hubspoke?ref=v2.0.0"

  location           = var.location
  environment        = var.environment
  deploy_environment = var.deploy_environment
  workload_name      = var.workload_name
  org_name           = var.org_name
  metadata_host      = var.metadata_host

  add_tags = local.common_tags
}
{%- endif %}
{%- if 'workloadspoke' in values.modules %}

#################################
# Workload Spoke                #
#################################
module "mod_workloadspoke" {
  source = "github.com/POps-Rox/terraform-az-overlays-workloadspoke?ref=v2.0.0"

  location           = var.location
  environment        = var.environment
  deploy_environment = var.deploy_environment
  workload_name      = var.workload_name
  org_name           = var.org_name
  metadata_host      = var.metadata_host

  add_tags = local.common_tags
}
{%- endif %}
{%- if 'managementhub' in values.modules %}

module "mod_managementhub" {
  source = "github.com/POps-Rox/terraform-az-overlays-managementhub?ref=v2.0.0"

  location           = var.location
  environment        = var.environment
  deploy_environment = var.deploy_environment
  workload_name      = var.workload_name
  org_name           = var.org_name
  metadata_host      = var.metadata_host

  add_tags = local.common_tags
}
{%- endif %}
{%- if 'managementspoke' in values.modules %}

module "mod_managementspoke" {
  source = "github.com/POps-Rox/terraform-az-overlays-managementspoke?ref=v2.0.0"

  location           = var.location
  environment        = var.environment
  deploy_environment = var.deploy_environment
  workload_name      = var.workload_name
  org_name           = var.org_name
  metadata_host      = var.metadata_host

  add_tags = local.common_tags
}
{%- endif %}
{%- if 'dmzspoke' in values.modules %}

module "mod_dmzspoke" {
  source = "github.com/POps-Rox/terraform-az-overlays-dmzspoke?ref=v2.0.0"

  location           = var.location
  environment        = var.environment
  deploy_environment = var.deploy_environment
  workload_name      = var.workload_name
  org_name           = var.org_name
  metadata_host      = var.metadata_host

  add_tags = local.common_tags
}
{%- endif %}
{%- if 'virtualmachine' in values.modules %}

module "mod_vm" {
  source = "github.com/POps-Rox/terraform-az-overlays-virtualmachine?ref=v2.0.0"

  location           = var.location
  environment        = var.environment
  deploy_environment = var.deploy_environment
  workload_name      = var.workload_name
  org_name           = var.org_name
  metadata_host      = var.metadata_host

  {%- if 'resourcegroup' in values.modules %}
  existing_resource_group_name = module.mod_resource_group.resource_group_name
  create_resource_group        = false
  {%- endif %}

  add_tags = local.common_tags
}
{%- endif %}
{%- if 'bastionhost' in values.modules %}

module "mod_bastion" {
  source = "github.com/POps-Rox/terraform-az-overlays-bastionhost?ref=v2.0.0"

  location           = var.location
  environment        = var.environment
  deploy_environment = var.deploy_environment
  workload_name      = var.workload_name
  org_name           = var.org_name
  metadata_host      = var.metadata_host

  {%- if 'resourcegroup' in values.modules %}
  existing_resource_group_name = module.mod_resource_group.resource_group_name
  create_resource_group        = false
  {%- endif %}

  add_tags = local.common_tags
}
{%- endif %}
{%- if 'vnetpeering' in values.modules %}

module "mod_vnetpeering" {
  source = "github.com/POps-Rox/terraform-az-overlays-vnetpeering?ref=v2.0.0"

  location           = var.location
  environment        = var.environment
  deploy_environment = var.deploy_environment
  workload_name      = var.workload_name
  org_name           = var.org_name
  metadata_host      = var.metadata_host

  add_tags = local.common_tags
}
{%- endif %}
{%- if 'wafpolicy' in values.modules %}

module "mod_wafpolicy" {
  source = "github.com/POps-Rox/terraform-az-overlays-wafpolicy?ref=v2.0.0"

  location           = var.location
  environment        = var.environment
  deploy_environment = var.deploy_environment
  workload_name      = var.workload_name
  org_name           = var.org_name
  metadata_host      = var.metadata_host

  {%- if 'resourcegroup' in values.modules %}
  existing_resource_group_name = module.mod_resource_group.resource_group_name
  create_resource_group        = false
  {%- endif %}

  add_tags = local.common_tags
}
{%- endif %}
{%- if 'sentinel' in values.modules %}

module "mod_sentinel" {
  source = "github.com/POps-Rox/terraform-az-overlays-sentinel?ref=v2.0.0"

  location           = var.location
  environment        = var.environment
  deploy_environment = var.deploy_environment
  workload_name      = var.workload_name
  org_name           = var.org_name
  metadata_host      = var.metadata_host

  add_tags = local.common_tags
}
{%- endif %}
{%- if 'defenderforcloud' in values.modules %}

module "mod_defender" {
  source = "github.com/POps-Rox/terraform-az-overlays-defenderforcloud?ref=v2.0.0"
}
{%- endif %}
{%- if 'diagnosticsettings' in values.modules %}

module "mod_diagnostics" {
  source = "github.com/POps-Rox/terraform-az-overlays-diagnosticsettings?ref=v2.0.0"

  location           = var.location
  environment        = var.environment
  deploy_environment = var.deploy_environment
  workload_name      = var.workload_name
  org_name           = var.org_name
  metadata_host      = var.metadata_host

  add_tags = local.common_tags
}
{%- endif %}
