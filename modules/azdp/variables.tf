variable "resource_group_name" {
  type        = string
  description = "Resource Group Name"
}

variable "location" {
  type        = string
  description = "Azure Location"
  default     = "eastus"
  // TODO: Add Location Validation
}

variable "environment" {
  type        = string
  description = "Lifecycle Environment"
  validation {
    condition     = length(var.environment) < 4
    error_message = "The environment variable must be less than 4 characters."
  }
}

variable "revision" {
  type        = number
  description = "Revision Number"
  default     = 1
}

variable "organization" {
  type        = string
  description = "Organization"
  validation {
    condition     = length(var.organization) <= 4
    error_message = "The organization variable must be 4 characters or less."
  }
}
variable "application" {
  type        = string
  description = "Application"
  default     = ""
}

variable "tags" {
  type        = map(string)
  description = "Tags to include on all resources"
  default = {
  }
}

variable "override_resource_names" {
  type        = map(string)
  description = "Override Resource Names"
  default = {

  }
}

variable "account_replication_type" {
  type        = string
  description = "Storage Account Replication Type"
  default     = "RAGRS"
}
variable "blob_delete_retention_policy_days" {
  type        = number
  description = "Blob Delete Retention Policy (days)"
  default     = 7
}

variable "container_delete_retention_policy_days" {
  type        = number
  description = "Container Delete Retention Policy (days)"
  default     = 7
}

variable "ip_rules" {
  type        = set(string)
  description = "List of public IP or IP ranges in CIDR Format. Only IPV4 addresses are allowed. Private IP address ranges (as defined in RFC 1918) are not allowed."
  default     = []
  // TODO: Validate IP Address including CIDR masks
}

variable "virtual_network_subnet_ids" {
  type        = list(string)
  description = "A list of virtual network subnet ids to to secure the storage account"
  default     = []
}

variable "filesystems" {
  type        = set(string)
  description = "Set of Filesystems to create in the Data Lake"
  default     = []
}

variable "adls_readers" {
  type        = set(string)
  description = "Set of Principal IDs that can read the entire ADLS"
  default     = []
  validation {
    condition     = alltrue([for oid in var.adls_readers : can(regex("^[0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}$", oid))])
    error_message = "Variable adls_readers does not contain parseable Object IDs."
  }
}

variable "adls_contributors" {
  type        = set(string)
  description = "Set of Principal IDs with read and write permissions on the entire ADLS"
  default     = []
  validation {
    condition     = alltrue([for oid in var.adls_contributors : can(regex("^[0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}$", oid))])
    error_message = "Variable adls_contributors does not contain parseable Object IDs."
  }
}

variable "adls_filesystem_readers" {
  type        = map(set(string))
  description = "Map a filesystem to a set of Principal IDs with read permission in ADLS"
  default     = {}
}

variable "adls_filesystem_contributors" {
  type        = map(set(string))
  description = "Map a filesystem to a set of Principal IDs with read/write permissions in ADLS"
  default     = {}
}

variable "sql_administrator_login" {
  type        = string
  description = "SQL Administrator Login for Synapse workspace."
  default     = "SQLAdmin"
}

variable "sql_administrator_login_password" {
  type        = string
  description = "SQL Administration Login Password for Synapse workspace."
  sensitive   = true
}

variable "sql_aad_admin_login" {
  type        = string
  description = "SQL Login Name for the AAD Admin"
  default     = "SQLAADAdmin"
}

variable "sql_aad_admin_object_id" {
  type        = string
  description = "Object ID of the Principal (User or Group) for the AAD Admin"
  default     = ""
}
variable "sql_aad_admin_tenant_id" {
  type        = string
  description = "Tenant ID of AAD"
  default     = ""
}

variable "log_analytics_retention_days" {
  type        = number
  description = "Log Analytics Retention Days"
  default     = 30
}

variable "security_alert_email_addresses" {
  type        = set(string)
  description = "List of email addresses to notify for security alerts"
  default     = []
}

variable "synapse_administrators" {
  type        = set(string)
  description = "Set of Principal IDs that can administer the Synapse workspace"
  default     = []
  validation {
    condition     = alltrue([for oid in var.synapse_administrators : can(regex("^[0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}$", oid))])
    error_message = "Variable synapse_administrators does not contain parseable Object IDs."
  }
}

variable "synapse_contributors" {
  type        = set(string)
  description = "Set of Principal IDs that can contribute to the Synapse workspace"
  default     = []
  validation {
    condition     = alltrue([for oid in var.synapse_contributors : can(regex("^[0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}$", oid))])
    error_message = "Variable synapse_contributors does not contain parseable Object IDs."
  }
}

variable "synapse_users" {
  type        = set(string)
  description = "Set of Principal IDs that can use the Synapse workspace"
  default     = []
  validation {
    condition     = alltrue([for oid in var.synapse_users : can(regex("^[0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}$", oid))])
    error_message = "Variable synapse_users does not contain parseable Object IDs."
  }
}

variable "synapse_managed_virtual_network_enabled" {
  type        = bool
  default     = false
  description = "Managed Virtual Network enabled for all computes in this workspace"
}

variable "synapse_data_exfiltration_protection_enabled" {
  type        = bool
  default     = false
  description = "Data exfiltration protection enabled in this workspace. Managed Virtual Network must also be enabled."
}
