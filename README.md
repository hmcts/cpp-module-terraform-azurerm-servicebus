# cpp-module-terraform-azurerm-servicebus-namespace

Terraform module for [Azure Service Bus Namespace](https://learn.microsoft.com/en-us/azure/service-bus-messaging/service-bus-messaging-overview).

This module creates a Service Bus namespace with Zero Trust defaults: private endpoint only, Azure AD RBAC (no SAS keys), TLS 1.2 minimum, optional CMK (Premium), and diagnostic logs to Log Analytics.

## Requirements

- Terraform >= 1.14.6
- Azurerm provider ~> 4.62.1

## Security (Zero Trust)

- **public_network_access_enabled** = false by default (private endpoint only).
- **local_auth_enabled** = false (Azure AD RBAC only; no SAS keys).
- **minimum_tls_version** = "1.2".
- Private Endpoint for namespace access.
- Diagnostic logs sent to Log Analytics when `log_analytics_workspace_id` is set.
- Optional Customer-Managed Key (CMK) when SKU is Premium.

## SKU and CMK

- Default SKU is **Standard**. Use variable `sku` = "Premium" for Premium.
- **Capacity** is only valid when SKU is Premium
- **cmk_key_id**: when set, SKU must be Premium; Key Vault is not created by this module.

## Example (Dev – Standard)

```hcl
module "servicebus_namespace" {
  source = "../"
  name   = "sb-dev-001"
  resource_group_name           = azurerm_resource_group.main.name
  location                      = var.location
  environment                   = "dev"
  sku                           = "Standard"
  public_network_access_enabled = false
  private_endpoint_subnet_id    = var.private_endpoint_subnet_id
  log_analytics_workspace_id    = var.log_analytics_workspace_id
  tags                          = var.tags
}
```

## Example (Prod – Premium + CMK)

```hcl
module "servicebus_namespace" {
  source = "../"
  name   = "sb-prod-001"
  resource_group_name            = azurerm_resource_group.main.name
  location                       = var.location
  environment                    = "prd"
  sku                            = "Premium"
  capacity                       = 2
  zone_redundant                 = true
  public_network_access_enabled  = false
  private_endpoint_subnet_id     = var.private_endpoint_subnet_id
  private_dns_zone_id            = var.servicebus_private_dns_zone_id
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  cmk_key_id                     = var.cmk_key_id
  cmk_user_assigned_identity_id  = var.cmk_user_assigned_identity_id
  infrastructure_encryption_enabled = true
  tags                           = var.tags
}
```


## Terratest

We use test for testing terraform module.

```shell
cd tests/terratest
go test -v -count=1 -timeout 30m .
```

## Contributing

We use pre-commit for Terraform format/validate and terraform-docs for README.

```shell
brew install pre-commit terraform-docs
pre-commit install
pre-commit run --all-files
```

<!-- BEGIN_TF_DOCS -->


## Providers

The following providers are used by this module:

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm)

## Resources

The following resources are used by this module:

- [azurerm_monitor_diagnostic_setting.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) (resource)
- [azurerm_private_endpoint.namespace](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) (resource)
- [azurerm_role_assignment.namespace](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [azurerm_role_assignment.queue](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [azurerm_role_assignment.subscription](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [azurerm_role_assignment.topic](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [azurerm_servicebus_namespace.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_namespace) (resource)
- [azurerm_servicebus_queue.queue](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_queue) (resource)
- [azurerm_servicebus_subscription.subscription](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_subscription) (resource)
- [azurerm_servicebus_topic.topic](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_topic) (resource)

## Required Inputs

The following input variables are required:

### <a name="input_name"></a> [name](#input\_name)

Description: The name of the Service Bus namespace. Must be between 6 and 50 characters.

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The name of the resource group in which to create the Service Bus namespace.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_capacity"></a> [capacity](#input\_capacity)

Description: Specifies the capacity. Only applicable when sku is Premium. Can be 1, 2, 4, 8 or 16.

Type: `number`

Default: `0`

### <a name="input_cmk_key_id"></a> [cmk\_key\_id](#input\_cmk\_key\_id)

Description: Customer-managed key ID (Key Vault key resource ID). When provided, SKU must be Premium. Do not provision Key Vault in this module.

Type: `string`

Default: `null`

### <a name="input_cmk_user_assigned_identity_id"></a> [cmk\_user\_assigned\_identity\_id](#input\_cmk\_user\_assigned\_identity\_id)

Description: User-Assigned Identity resource ID used to access the Key Vault for CMK. Required when cmk\_key\_id is set.

Type: `string`

Default: `null`

### <a name="input_environment"></a> [environment](#input\_environment)

Description: Environment into which resource is deployed.

Type: `string`

Default: `""`

### <a name="input_infrastructure_encryption_enabled"></a> [infrastructure\_encryption\_enabled](#input\_infrastructure\_encryption\_enabled)

Description: Whether infrastructure encryption is enabled for CMK. Only applicable when cmk\_key\_id is set.

Type: `bool`

Default: `false`

### <a name="input_location"></a> [location](#input\_location)

Description: The Azure region in which to create the Service Bus namespace.

Type: `string`

Default: `"uksouth"`

### <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id)

Description: Log Analytics workspace ID for diagnostic logs and metrics.

Type: `string`

Default: `null`

### <a name="input_managed_identity_ids"></a> [managed\_identity\_ids](#input\_managed\_identity\_ids)

Description: List of User-Assigned Managed Identity resource IDs to assign to the namespace.

Type: `list(string)`

Default: `[]`

### <a name="input_premium_messaging_partitions"></a> [premium\_messaging\_partitions](#input\_premium\_messaging\_partitions)

Description: Number of partitions (1, 2, or 4). Defaults to capacity if not set.

Type: `number`

Default: `null`

### <a name="input_private_dns_zone_id"></a> [private\_dns\_zone\_id](#input\_private\_dns\_zone\_id)

Description: Private DNS zone ID for Service Bus (privatelink.servicebus.windows.net). Optional; if provided the private endpoint will be linked.

Type: `string`

Default: `null`

### <a name="input_private_endpoint_subnet_id"></a> [private\_endpoint\_subnet\_id](#input\_private\_endpoint\_subnet\_id)

Description: Subnet ID for the private endpoint. Required when public\_network\_access\_enabled is false.

Type: `string`

Default: `null`

### <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled)

Description: Whether public network access is enabled. Set to false for Zero Trust (private endpoint only).

Type: `bool`

Default: `false`

### <a name="input_queues"></a> [queues](#input\_queues)

Description: Optional map of queues. Key = queue name. No queues created if null or empty.

Type:

```hcl
map(object({
    max_delivery_count                   = optional(number, 10)
    dead_lettering_on_message_expiration = optional(bool, false)
    default_message_ttl                 = optional(string)
    lock_duration                       = optional(string)
    requires_duplicate_detection            = optional(bool, false)
    duplicate_detection_history_time_window = optional(string)
    requires_session                    = optional(bool, false)
    role_assignments = optional(list(object({
      role_name = string
      object_id = string
    })), [])
  }))
```

Default: `null`

### <a name="input_role_assignments"></a> [role\_assignments](#input\_role\_assignments)

Description: Namespace-level role assignments. Use only when access to all entities in the namespace is required (least privilege: prefer queue/topic/subscription-level assignments).

Type:

```hcl
list(object({
    role_name = string
    object_id = string
  }))
```

Default: `[]`

### <a name="input_sku"></a> [sku](#input\_sku)

Description: SKU for the Service Bus namespace. Valid values are Basic, Standard, Premium. Default is Standard.

Type: `string`

Default: `"Standard"`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: A mapping of tags to assign to the resource.

Type: `map(string)`

Default: `{}`

### <a name="input_topics"></a> [topics](#input\_topics)

Description: Optional map of topics. Key = topic name. Each topic may have optional subscriptions. No topics/subscriptions created if null or empty.

Type:

```hcl
map(object({
    default_message_ttl           = optional(string)
    max_size_in_megabytes        = optional(number)
    requires_duplicate_detection = optional(bool, false)
    duplicate_detection_history_time_window = optional(string)
    role_assignments = optional(list(object({
      role_name = string
      object_id = string
    })), [])
    subscriptions = optional(map(object({
      max_delivery_count                   = optional(number, 10)
      dead_lettering_on_message_expiration = optional(bool, false)
      default_message_ttl                 = optional(string)
      lock_duration                       = optional(string)
      role_assignments = optional(list(object({
        role_name = string
        object_id = string
      })), [])
    })), {})
  }))
```

Default: `null`

## Outputs

The following outputs are exported:

### <a name="output_private_endpoint_id"></a> [private\_endpoint\_id](#output\_private\_endpoint\_id)

Description: The ID of the private endpoint, if created.

### <a name="output_queues"></a> [queues](#output\_queues)

Description: Map of queue names to queue resource IDs.

### <a name="output_servicebus_namespace_endpoint"></a> [servicebus\_namespace\_endpoint](#output\_servicebus\_namespace\_endpoint)

Description: The endpoint of the Service Bus namespace.

### <a name="output_servicebus_namespace_id"></a> [servicebus\_namespace\_id](#output\_servicebus\_namespace\_id)

Description: The ID of the Service Bus namespace.

### <a name="output_servicebus_namespace_name"></a> [servicebus\_namespace\_name](#output\_servicebus\_namespace\_name)

Description: The name of the Service Bus namespace.

### <a name="output_servicebus_namespace_principal_id"></a> [servicebus\_namespace\_principal\_id](#output\_servicebus\_namespace\_principal\_id)

Description: The Principal ID for the Service Bus namespace system-assigned identity (when no user-assigned identities).

### <a name="output_subscriptions"></a> [subscriptions](#output\_subscriptions)

Description: Map of 'topic\_name|subscription\_name' to subscription resource IDs.

### <a name="output_topics"></a> [topics](#output\_topics)

Description: Map of topic names to topic resource IDs.
<!-- END_TF_DOCS -->
