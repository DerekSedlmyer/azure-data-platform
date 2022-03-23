resource "azurerm_log_analytics_workspace" "log_analytics_ws" {
  name                = local.resource_names["log_analytics_workspace"]
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_analytics_retention_days

  tags = merge(local.effective_tags,
    tomap(
      {
        "azdp_component" : "log_analytics_workspace"
      }
    )
  )
}

resource "azurerm_storage_account" "audit_logs" {
  name = local.resource_names["audit_logs_storage_account"]

  location            = var.location
  resource_group_name = var.resource_group_name

  tags = merge(local.effective_tags,
    tomap(
      {
        "azdp_component" : "audit_logs"
      }
    )
  )

  access_tier               = "Hot"
  account_kind              = "StorageV2"
  account_replication_type  = "LRS"
  account_tier              = "Standard"
  allow_blob_public_access  = false
  enable_https_traffic_only = true
  min_tls_version           = "TLS1_2"
  shared_access_key_enabled = true
}

resource "azurerm_storage_container" "synapse_assessments" {
  name                  = "synapse-assessments"
  storage_account_name  = azurerm_storage_account.audit_logs.name
  container_access_type = "private"
}


