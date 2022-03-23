resource "azurerm_synapse_workspace" "synapse_workspace" {
  resource_group_name = var.resource_group_name
  location            = var.location

  name = local.resource_names["synapse_workspace"]

  tags = merge(local.effective_tags,
    tomap(
      {
        "azdp_component" : "synapse_ws"
      }
    )
  )

  sql_administrator_login          = var.sql_administrator_login
  sql_administrator_login_password = var.sql_administrator_login_password

  aad_admin {
    login     = var.sql_aad_admin_login
    object_id = local.sql_aad_admin_object_id
    tenant_id = local.sql_aad_admin_tenant_id
  }

  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.adls_synapse_filesystem.id

  managed_virtual_network_enabled      = var.synapse_managed_virtual_network_enabled
  data_exfiltration_protection_enabled = var.synapse_data_exfiltration_protection_enabled
}

resource "azurerm_storage_data_lake_gen2_filesystem" "adls_synapse_filesystem" {
  depends_on = [
    azurerm_storage_account_network_rules.adls_network_rules,
    azurerm_role_assignment.rg_storage_blob_data_contributor_self
  ]

  name               = "synapse"
  storage_account_id = azurerm_storage_account.adls.id
}

resource "azurerm_synapse_firewall_rule" "allow_azure_services" {
  name                 = "AllowAllWindowsAzureIps"
  synapse_workspace_id = azurerm_synapse_workspace.synapse_workspace.id
  start_ip_address     = "0.0.0.0"
  end_ip_address       = "0.0.0.0"
}

resource "azurerm_synapse_firewall_rule" "allow_public_ip" {
  for_each = var.ip_rules

  name                 = "Allow-${replace(each.value, ".", "-")}"
  synapse_workspace_id = azurerm_synapse_workspace.synapse_workspace.id

  start_ip_address = each.value
  end_ip_address   = each.value
}

resource "azurerm_synapse_workspace_security_alert_policy" "synapse_security_alert_policy" {
  synapse_workspace_id         = azurerm_synapse_workspace.synapse_workspace.id
  policy_state                 = "Enabled"
  storage_endpoint             = azurerm_storage_account.audit_logs.primary_blob_endpoint
  storage_account_access_key   = azurerm_storage_account.audit_logs.primary_access_key
  retention_days               = 0
  email_account_admins_enabled = true
  email_addresses              = var.security_alert_email_addresses
}

resource "azurerm_synapse_workspace_vulnerability_assessment" "synapse_vulnerability_assessment" {
  workspace_security_alert_policy_id = azurerm_synapse_workspace_security_alert_policy.synapse_security_alert_policy.id
  storage_container_path             = "${azurerm_storage_account.audit_logs.primary_blob_endpoint}${azurerm_storage_container.synapse_assessments.name}/"
  storage_account_access_key         = azurerm_storage_account.audit_logs.primary_access_key

  recurring_scans {
    enabled                           = true
    email_subscription_admins_enabled = true
    emails                            = var.security_alert_email_addresses
  }
}

resource "azurerm_synapse_workspace_extended_auditing_policy" "synapse_extended_audit_policy" {
  synapse_workspace_id                    = azurerm_synapse_workspace.synapse_workspace.id
  storage_endpoint                        = azurerm_storage_account.audit_logs.primary_blob_endpoint
  storage_account_access_key              = azurerm_storage_account.audit_logs.primary_access_key
  storage_account_access_key_is_secondary = false
}

resource "azurerm_monitor_diagnostic_setting" "synapse_ws_diagnostics_log" {
  name                       = "${azurerm_synapse_workspace.synapse_workspace.name}-log"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log_analytics_ws.id

  target_resource_id = azurerm_synapse_workspace.synapse_workspace.id

  log {
    category = "SynapseRbacOperations"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = false
    }
  }
  log {
    category = "GatewayApiRequests"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = false
    }
  }
  log {
    category = "BuiltinSqlReqsEnded"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = false
    }
  }
  log {
    category = "IntegrationPipelineRuns"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = false
    }
  }
  log {
    category = "IntegrationActivityRuns"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = false
    }
  }
  log {
    category = "IntegrationTriggerRuns"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = false
    }
  }
  log {
    category = "SQLSecurityAuditEvents"
    enabled  = false
    retention_policy {
      days    = 0
      enabled = false
    }
  }
  metric {
    category = "AllMetrics"
    enabled  = false
    retention_policy {
      days    = 0
      enabled = false
    }
  }
}

resource "time_sleep" "wait_for_public_ip" {
  depends_on = [azurerm_synapse_firewall_rule.allow_public_ip]

  create_duration = "2m"
}

resource "azurerm_synapse_role_assignment" "synapse_administrators" {
  depends_on = [
    time_sleep.wait_for_public_ip
  ]

  for_each = var.synapse_administrators

  synapse_workspace_id = azurerm_synapse_workspace.synapse_workspace.id

  role_name    = "Synapse Administrator"
  principal_id = each.value
}

resource "azurerm_synapse_role_assignment" "synapse_contributors" {
  depends_on = [
    time_sleep.wait_for_public_ip
  ]

  for_each = var.synapse_contributors

  synapse_workspace_id = azurerm_synapse_workspace.synapse_workspace.id

  role_name    = "Synapse Contributor"
  principal_id = each.value
}

resource "azurerm_synapse_role_assignment" "synapse_users" {
  depends_on = [
    time_sleep.wait_for_public_ip
  ]

  for_each = var.synapse_users

  synapse_workspace_id = azurerm_synapse_workspace.synapse_workspace.id

  role_name    = "Synapse User"
  principal_id = each.value
}

resource "azurerm_role_assignment" "adls_contributor_synapse" {
  scope                = azurerm_storage_account.adls.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_synapse_workspace.synapse_workspace.identity[0].principal_id
}

resource "azurerm_role_assignment" "key_vault_reader_synapse" {
  scope                = azurerm_key_vault.key_vault.id
  role_definition_name = "Key Vault Reader"
  principal_id         = azurerm_synapse_workspace.synapse_workspace.identity[0].principal_id
}

resource "azurerm_role_assignment" "key_vault_secret_user_synapse" {
  scope                = azurerm_key_vault.key_vault.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_synapse_workspace.synapse_workspace.identity[0].principal_id
}
