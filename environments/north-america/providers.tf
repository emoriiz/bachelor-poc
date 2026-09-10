# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.80.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  subscription_id                 = var.subscription_id
  resource_provider_registrations = "none" # This is only required when the User, Service Principal, or Identity running Terraform lacks the permissions to register Azure Resource Providers.

  features {
    # Erlaubt das Loeschen einer Resource Group, in der noch von Terraform
    # verwaltete Ressourcen liegen. Noetig, weil ein Regionswechsel die RG
    # neu anlegen muss, verschachtelte Ressourcen (z.B. die Private DNS Zone)
    # aber nicht automatisch mit ersetzt werden.
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}
