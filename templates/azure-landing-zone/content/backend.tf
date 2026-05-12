terraform {
  backend "azurerm" {
    # Populated by the terraform-overlays-remotestate accelerator.
    # resource_group_name  = "popsrox-remotestate-rg"
    # storage_account_name = "popsroxtfstate"
    # container_name       = "tfstate"
    # key                  = "landing-zones/${{ values.enclave_name }}.tfstate"
  }
}
