# Remote state backend.
#
# This file uses the Azure Storage backend produced by the
# `terraform-overlays-remotestate` accelerator. Bootstrap that repo once per
# subscription to create the state RG, storage account, container, and SPN,
# then update the values below (or supply them at `terraform init` time via
# `-backend-config=`). See the README for the bootstrap workflow.
terraform {
  backend "azurerm" {
    # resource_group_name  = "popsrox-remotestate-rg"
    # storage_account_name = "popsroxtfstate"
    # container_name       = "tfstate"
    # key                  = "${{ values.name }}/${{ values.environment }}.tfstate"
  }
}
