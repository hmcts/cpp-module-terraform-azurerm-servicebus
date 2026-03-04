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
