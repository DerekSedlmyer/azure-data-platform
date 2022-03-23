resource "azurerm_storage_account" "adls" {
  resource_group_name = var.resource_group_name
  location            = var.location

  name = local.resource_names["adls"]

  tags = merge(local.effective_tags,
    tomap(
      {
        "azdp_component" : "adls"
      }
    )
  )

  access_tier               = "Hot"
  account_kind              = "StorageV2"
  account_replication_type  = var.account_replication_type
  account_tier              = "Standard"
  allow_blob_public_access  = false
  enable_https_traffic_only = true
  is_hns_enabled            = true
  min_tls_version           = "TLS1_2"
  shared_access_key_enabled = true
  nfsv3_enabled             = false
  large_file_share_enabled  = false

  blob_properties {
    delete_retention_policy {
      days = var.blob_delete_retention_policy_days
    }

    container_delete_retention_policy {
      days = var.container_delete_retention_policy_days
    }

    versioning_enabled       = false
    change_feed_enabled      = false
    default_service_version  = "2020-06-12"
    last_access_time_enabled = false
  }
}

resource "azurerm_storage_account_network_rules" "adls_network_rules" {
  storage_account_id = azurerm_storage_account.adls.id

  default_action             = "Deny"
  bypass                     = ["AzureServices", "Metrics"]
  ip_rules                   = var.ip_rules
  virtual_network_subnet_ids = var.virtual_network_subnet_ids

}

resource "azurerm_storage_data_lake_gen2_filesystem" "adls_filesystems" {
  depends_on = [
    azurerm_storage_account_network_rules.adls_network_rules,
    azurerm_role_assignment.rg_storage_blob_data_contributor_self
  ]

  for_each = var.filesystems

  name               = each.key
  storage_account_id = azurerm_storage_account.adls.id
}



resource "azurerm_role_assignment" "adls_readers" {
  for_each = var.adls_readers

  scope                = azurerm_storage_account.adls.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = each.key
}

resource "azurerm_role_assignment" "adls_contributors" {
  for_each = var.adls_contributors

  scope                = azurerm_storage_account.adls.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = each.key
}

resource "azurerm_role_assignment" "adls_filesystem_readers" {

  depends_on = [
    azurerm_storage_account_network_rules.adls_network_rules,
    azurerm_role_assignment.rg_storage_blob_data_contributor_self
  ]

  for_each = {
    for o in local.adls_filesystem_readers_list : "${o.filesystem}.${o.principal_id}" => o
  }


  scope                = "${azurerm_storage_account.adls.id}/blobServices/default/containers/${each.value.filesystem}"
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = each.value.principal_id
}

resource "azurerm_role_assignment" "adls_filesystem_contributors" {

  depends_on = [
    azurerm_storage_account_network_rules.adls_network_rules,
    azurerm_role_assignment.rg_storage_blob_data_contributor_self
  ]

  for_each = {
    for o in local.adls_filesystem_contributors_list : "${o.filesystem}.${o.principal_id}" => o
  }

  scope                = "${azurerm_storage_account.adls.id}/blobServices/default/containers/${each.value.filesystem}"
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = each.value.principal_id
}
