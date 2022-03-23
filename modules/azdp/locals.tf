locals {
  effective_tags = merge(
    var.tags,
    tomap(
      {
        "organization" : var.organization,
        "application" : var.application,
        "revision" : var.revision
      }
    )
  )

  short_location = local.short_locations[var.location]

  resource_names = merge(var.override_resource_names, {
    key_vault                  = format("kv%s%s%s%s%02d", var.organization, var.application, var.environment, local.short_location, var.revision)
    adls                       = format("adls%s%s%s%s%02d", var.organization, var.application, var.environment, local.short_location, var.revision)
    synapse_workspace          = format("syn-%s-%s-%s-%s-%02d", var.organization, var.application, var.environment, local.short_location, var.revision)
    log_analytics_workspace    = format("log-%s-%s-%s-%s-%02d", var.organization, var.application, var.environment, local.short_location, var.revision)
    audit_logs_storage_account = format("salogs%s%s%s%s%02d", var.organization, var.application, var.environment, local.short_location, var.revision)
  })

  short_locations = {
    "eastus" : "eus",
    "eastus2" : "eus2",
    "westus" : "wus",
    "westus2" : "wus2",
    "centralus" : "cus"
  }

  adls_filesystem_readers_list = flatten([
    for filesystem, oids in var.adls_filesystem_readers : [
      for principal_id in oids : {
        filesystem   = filesystem
        principal_id = principal_id
      }
    ]
  ])

  adls_filesystem_contributors_list = flatten([
    for filesystem, oids in var.adls_filesystem_contributors : [
      for principal_id in oids : {
        filesystem   = filesystem
        principal_id = principal_id
      }
    ]
  ])


  sql_aad_admin_object_id = var.sql_aad_admin_object_id == "" ? data.azurerm_client_config.current.object_id : var.sql_aad_admin_object_id
  sql_aad_admin_tenant_id = var.sql_aad_admin_tenant_id == "" ? data.azurerm_client_config.current.tenant_id : var.sql_aad_admin_tenant_id
}