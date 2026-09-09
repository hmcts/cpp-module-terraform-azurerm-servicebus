variable "name" {
  description = "The name of the Service Bus namespace. Must be between 6 and 50 characters."
  type        = string
  validation {
    condition     = length(var.name) >= 6 && length(var.name) <= 50
    error_message = "The 'name' variable must be between 6 and 50 characters long."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Service Bus namespace."
  type        = string
}

variable "location" {
  description = "The Azure region in which to create the Service Bus namespace."
  type        = string
  default     = "uksouth"
}

variable "environment" {
  description = "Environment into which resource is deployed."
  type        = string
  default     = ""
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}

variable "sku" {
  description = "SKU for the Service Bus namespace. Valid values are Basic, Standard, Premium. Default is Standard."
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "The 'sku' variable must be one of: Basic, Standard, Premium."
  }
}

variable "capacity" {
  description = "Specifies the capacity. Only applicable when sku is Premium. Can be 1, 2, 4, 8 or 16."
  type        = number
  default     = 0
}

variable "premium_messaging_partitions" {
  description = "Number of partitions (1, 2, or 4). Defaults to capacity if not set."
  type        = number
  default     = null
}

variable "public_network_access_enabled" {
  description = "Whether public network access is enabled. Set to false for Zero Trust (private endpoint only)."
  type        = bool
  default     = false
}

variable "private_endpoint_subnet_id" {
  description = "Subnet ID for the private endpoint. Required when public_network_access_enabled is false."
  type        = string
  default     = null
}

variable "private_dns_zone_id" {
  description = "Private DNS zone ID for Service Bus (privatelink.servicebus.windows.net). Optional; if provided the private endpoint will be linked."
  type        = string
  default     = null
}

variable "local_auth_enabled" {
  description = "Whether local authentication is enabled. Set to false for Entra Authentication only."
  type        = bool
  default     = false
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for diagnostic logs and metrics."
  type        = string
  default     = null
}

variable "managed_identity_ids" {
  description = "List of User-Assigned Managed Identity resource IDs to assign to the namespace."
  type        = list(string)
  default     = []
}

variable "cmk_key_id" {
  description = "Customer-managed key ID (Key Vault key resource ID). When provided, SKU must be Premium. Do not provision Key Vault in this module."
  type        = string
  default     = null
}

variable "cmk_user_assigned_identity_id" {
  description = "User-Assigned Identity resource ID used to access the Key Vault for CMK. Required when cmk_key_id is set."
  type        = string
  default     = null
}

variable "infrastructure_encryption_enabled" {
  description = "Whether infrastructure encryption is enabled for CMK. Only applicable when cmk_key_id is set."
  type        = bool
  default     = false
}

variable "role_assignments" {
  description = "Namespace-level role assignments. Use only when access to all entities in the namespace is required (least privilege: prefer queue/topic/subscription-level assignments)."
  type = list(object({
    role_name = string
    object_id = string
  }))
  default = []
}

variable "queues" {
  description = "Optional map of queues. Key = queue name. No queues created if null or empty."
  type = map(object({
    max_delivery_count                      = optional(number, 10)
    dead_lettering_on_message_expiration    = optional(bool, false)
    default_message_ttl                     = optional(string)
    lock_duration                           = optional(string)
    requires_duplicate_detection            = optional(bool, false)
    duplicate_detection_history_time_window = optional(string)
    requires_session                        = optional(bool, false)
    role_assignments = optional(list(object({
      role_name = string
      object_id = string
    })), [])
  }))
  default = null
}

variable "topics" {
  description = "Optional map of topics. Key = topic name. Each topic may have optional subscriptions. No topics/subscriptions created if null or empty."
  type = map(object({
    default_message_ttl                     = optional(string)
    max_size_in_megabytes                   = optional(number)
    requires_duplicate_detection            = optional(bool, false)
    duplicate_detection_history_time_window = optional(string)
    role_assignments = optional(list(object({
      role_name = string
      object_id = string
    })), [])
    subscriptions = optional(map(object({
      max_delivery_count                   = optional(number, 10)
      dead_lettering_on_message_expiration = optional(bool, false)
      default_message_ttl                  = optional(string)
      lock_duration                        = optional(string)
      role_assignments = optional(list(object({
        role_name = string
        object_id = string
      })), [])
    })), {})
  }))
  default = null
}
