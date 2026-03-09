variable "location" {
  type    = string
  default = "uksouth"
}

variable "namespace" {
  type        = string
  default     = ""
  description = "Namespace, which could be an organization name or abbreviation."
}

variable "costcode" {
  type        = string
  description = "Cost code from project portfolio."
  default     = ""
}

variable "owner" {
  type        = string
  description = "Name of the project or squad which manages the resource."
  default     = ""
}

variable "application" {
  type        = string
  description = "Application to which the resource relates."
  default     = ""
}

variable "attribute" {
  type        = string
  description = "An attribute that makes the resource unique."
  default     = ""
}

variable "environment" {
  type        = string
  description = "Environment into which resource is deployed."
  default     = ""
}

variable "type" {
  type        = string
  description = "Name of service type."
  default     = ""
}

variable "version_number" {
  type        = string
  description = "Version of the application or object being deployed."
  default     = ""
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
  default     = "rg-lab-cpp-sbterratest"
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}

variable "name" {
  description = "The name of the Service Bus namespace (6-50 characters)."
  type        = string
}

variable "vnet_name" {
  type    = string
  default = "vnet-lab-cpp-sbterratest"
}

variable "sku" {
  description = "SKU: Basic, Standard, or Premium."
  type        = string
  default     = "Standard"
}

variable "public_network_access_enabled" {
  description = "Whether public network access is enabled."
  type        = bool
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for diagnostics."
  type        = string
  default     = null
}

variable "capacity" {
  description = "Capacity for Premium SKU (1, 2, 4, 8, 16)."
  type        = number
  default     = null
}

variable "zone_redundant" {
  description = "Zone redundancy (Premium only)."
  type        = bool
  default     = false
}

variable "cmk_key_id" {
  description = "Customer-managed key ID (Premium only)."
  type        = string
  default     = null
}

variable "cmk_user_assigned_identity_id" {
  description = "User-Assigned Identity for CMK key access."
  type        = string
  default     = null
}

variable "role_assignments" {
  description = "RBAC role assignments for the namespace."
  type = list(object({
    role_name = string
    object_id = string
  }))
  default = []
}

variable "queues" {
  description = "Optional queues (map). Omit or null for none."
  type        = map(any)
  default     = null
}

variable "topics" {
  description = "Optional topics with optional subscriptions (map). Omit or null for none."
  type        = map(any)
  default     = null
}
