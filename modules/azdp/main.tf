terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.91.0"
    }
  }
}

resource "azurerm_role_assignment" "rg_storage_blob_data_contributor_self" {
  scope                = data.azurerm_resource_group.rg.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}