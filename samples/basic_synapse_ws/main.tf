terraform {
  required_version = ">=1.1"
}

provider "azurerm" {
  features {}
}

locals {
  resource_group_name = format("rg-%s-%s-%s-%s-%02d", var.organization, var.application, var.environment, local.short_location, var.revision)
  short_locations = {
    "eastus" : "eus",
    "eastus2" : "eus2",
    "westus" : "wus",
    "westus2" : "wus2",
    "centralus" : "cus"
  }
  short_location = local.short_locations[var.location]
}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

resource "azurerm_resource_group" "resource_group" {
  name     = local.resource_group_name
  location = var.location
}


module "azdp" {
  source = "../../modules/azdp"

  depends_on = [
    azurerm_resource_group.resource_group
  ]

  resource_group_name = azurerm_resource_group.resource_group.name
  location            = var.location
  organization        = var.organization
  application         = var.application
  environment         = var.environment
  revision            = var.revision

  filesystems = ["raw", "staging", "drop", "products"]

  ip_rules = ["${chomp(data.http.myip.body)}"]

  adls_readers                 = var.adls_readers
  adls_contributors            = var.adls_contributors
  adls_filesystem_readers      = var.adls_filesystem_readers
  adls_filesystem_contributors = var.adls_filesystem_contributors

  sql_administrator_login          = "SQLAdmin"
  sql_administrator_login_password = "SQL@!12345"

  synapse_managed_virtual_network_enabled      = false
  synapse_data_exfiltration_protection_enabled = false

  synapse_administrators = var.synapse_administrators
  synapse_contributors   = var.synapse_contributors
  synapse_users          = var.synapse_users

  security_alert_email_addresses = ["dsedlmyer@ceiamerica.com"]
}
