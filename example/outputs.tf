output "subscription_id" {
  value = data.azurerm_subscription.current.subscription_id
}

output "resource_group_name" {
  value = azurerm_resource_group.test.name
}

output "servicebus_namespace_name" {
  value = module.servicebus_namespace.servicebus_namespace_name
}

output "servicebus_namespace_id" {
  value = module.servicebus_namespace.servicebus_namespace_id
}

output "private_endpoint_id" {
  description = "Set when public_network_access_enabled = false; used by zero-trust terratest."
  value       = module.servicebus_namespace.private_endpoint_id
}

output "private_dns_zone_id" {
  description = "Private DNS zone for Service Bus (privatelink.servicebus.windows.net). Set when using zero-trust example; used to assert DNS registration in terratest."
  value       = azurerm_private_dns_zone.servicebus.id
}

output "queues" {
  value     = module.servicebus_namespace.queues
  sensitive = false
}

output "topics" {
  value     = module.servicebus_namespace.topics
  sensitive = false
}

output "subscriptions" {
  value     = module.servicebus_namespace.subscriptions
  sensitive = false
}
