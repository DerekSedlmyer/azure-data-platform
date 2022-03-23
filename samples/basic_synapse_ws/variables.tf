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