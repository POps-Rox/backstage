terraform {
  required_version = ">= 1.10"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.20"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.0"
    }
    popsrox = {
      source  = "POps-Rox/azutils"
      version = "~> 1.0"
    }
  }
}

# A separate provider alias is configured for each subscription owned by
# the landing zone. The actual subscription IDs are wired in variables.tf
# and consumed by the module blocks in main.tf.

provider "azurerm" {
  features {}
  subscription_id = var.hub_subscription_id
}

provider "azurerm" {
  alias           = "identity"
  features {}
  subscription_id = var.identity_subscription_id
}

provider "azurerm" {
  alias           = "operations"
  features {}
  subscription_id = var.operations_subscription_id
}

provider "azurerm" {
  alias           = "workload"
  features {}
  subscription_id = var.workload_subscription_id
}
