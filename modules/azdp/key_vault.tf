resource "azurerm_key_vault" "key_vault" {
  resource_group_name = var.resource_group_name
  location            = var.location

  name      = local.resource_names["key_vault"]
  tenant_id = data.azurerm_client_config.current.tenant_id

  sku_name = "standard"

  enabled_for_disk_encryption     = true
  enable_rbac_authorization       = true
  enabled_for_deployment          = true
  enabled_for_template_deployment = true

  soft_delete_retention_days = 30
  purge_protection_enabled   = false

  tags = merge(local.effective_tags,
    tomap(
      {
        "azdp_component" : "key_vault"
      }
    )
  )
}

