output "servicebus_namespace_id" {
  description = "The ID of the Service Bus namespace."
  value       = azurerm_servicebus_namespace.main.id
}

output "servicebus_namespace_name" {
  description = "The name of the Service Bus namespace."
  value       = azurerm_servicebus_namespace.main.name
}

output "servicebus_namespace_endpoint" {
  description = "The endpoint of the Service Bus namespace."
  value       = azurerm_servicebus_namespace.main.endpoint
}

output "servicebus_namespace_principal_id" {
  description = "The Principal ID for the Service Bus namespace system-assigned identity (when no user-assigned identities)."
  value       = try(azurerm_servicebus_namespace.main.identity[0].principal_id, null)
}

output "private_endpoint_id" {
  description = "The ID of the private endpoint, if created."
  value       = try(azurerm_private_endpoint.namespace[0].id, null)
}

output "queues" {
  description = "Map of queue names to queue resource IDs."
  value       = { for k, q in azurerm_servicebus_queue.queue : k => q.id }
}

output "topics" {
  description = "Map of topic names to topic resource IDs."
  value       = { for k, t in azurerm_servicebus_topic.topic : k => t.id }
}

output "subscriptions" {
  description = "Map of 'topic_name|subscription_name' to subscription resource IDs."
  value       = { for k, s in azurerm_servicebus_subscription.subscription : k => s.id }
}
