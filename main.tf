resource "azurerm_servicebus_namespace" "main" {
  name                          = var.name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  sku                           = var.sku
  capacity                      = var.sku == local.premium_sku_name ? var.capacity : null
  premium_messaging_partitions  = var.sku == local.premium_sku_name ? local.effective_premium_messaging_partitions : null
  public_network_access_enabled = var.public_network_access_enabled
  minimum_tls_version           = "1.2"
  local_auth_enabled            = var.local_auth_enabled
  tags                          = var.tags

  identity {
    type         = length(var.managed_identity_ids) > 0 ? "SystemAssigned, UserAssigned" : "SystemAssigned"
    identity_ids = length(var.managed_identity_ids) > 0 ? var.managed_identity_ids : []
  }

  dynamic "customer_managed_key" {
    for_each = var.cmk_key_id != null && var.sku == local.premium_sku_name ? [1] : []
    content {
      key_vault_key_id                  = var.cmk_key_id
      identity_id                       = var.cmk_user_assigned_identity_id
      infrastructure_encryption_enabled = var.infrastructure_encryption_enabled
    }
  }
}

resource "azurerm_private_endpoint" "namespace" {
  count               = !var.public_network_access_enabled ? 1 : 0
  name                = "pe-sb-${azurerm_servicebus_namespace.main.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "psc-sb-${azurerm_servicebus_namespace.main.name}"
    private_connection_resource_id = azurerm_servicebus_namespace.main.id
    subresource_names              = ["namespace"]
    is_manual_connection           = false
  }

  dynamic "private_dns_zone_group" {
    for_each = var.private_dns_zone_id != null ? [1] : []
    content {
      name                 = "dns-zone-group-sb-${azurerm_servicebus_namespace.main.name}"
      private_dns_zone_ids = [var.private_dns_zone_id]
    }
  }

  tags = var.tags

  provisioner "local-exec" {
    command = "sleep ${local.post_private_endpoint_sleep_duration}"
  }
}

resource "azurerm_monitor_diagnostic_setting" "main" {
  count                      = var.log_analytics_workspace_id != null ? 1 : 0
  name                       = "diag-${azurerm_servicebus_namespace.main.name}"
  target_resource_id         = azurerm_servicebus_namespace.main.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "OperationalLogs"
  }
  enabled_log {
    category = "VNetAndIPFilteringLogs"
  }
  enabled_log {
    category = "RuntimeAuditLogs"
  }
  enabled_log {
    category = "ApplicationMetricsLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}

resource "azurerm_role_assignment" "namespace" {
  for_each = {
    for role in var.role_assignments :
    "${role.role_name}-${role.object_id}" => role
  }
  scope                = azurerm_servicebus_namespace.main.id
  role_definition_name = each.value.role_name
  principal_id         = each.value.object_id
}

resource "azurerm_servicebus_queue" "queue" {
  for_each     = local.queues_map
  name         = each.key
  namespace_id = azurerm_servicebus_namespace.main.id

  max_delivery_count                      = each.value.max_delivery_count
  dead_lettering_on_message_expiration    = each.value.dead_lettering_on_message_expiration
  default_message_ttl                     = each.value.default_message_ttl
  lock_duration                           = each.value.lock_duration
  requires_duplicate_detection            = each.value.requires_duplicate_detection
  duplicate_detection_history_time_window = each.value.duplicate_detection_history_time_window
  requires_session                        = each.value.requires_session
}

resource "azurerm_role_assignment" "queue" {
  for_each             = local.queue_role_assignments_flat
  scope                = azurerm_servicebus_queue.queue[each.value.queue_name].id
  role_definition_name = each.value.role_name
  principal_id         = each.value.object_id
}

resource "azurerm_servicebus_topic" "topic" {
  for_each     = local.topics_map
  name         = each.key
  namespace_id = azurerm_servicebus_namespace.main.id

  default_message_ttl                     = each.value.default_message_ttl
  max_size_in_megabytes                   = each.value.max_size_in_megabytes
  requires_duplicate_detection            = each.value.requires_duplicate_detection
  duplicate_detection_history_time_window = each.value.duplicate_detection_history_time_window
}

resource "azurerm_role_assignment" "topic" {
  for_each             = local.topic_role_assignments_flat
  scope                = azurerm_servicebus_topic.topic[each.value.topic_name].id
  role_definition_name = each.value.role_name
  principal_id         = each.value.object_id
}

resource "azurerm_servicebus_subscription" "subscription" {
  for_each = local.subscriptions_flat
  name     = each.value.subscription_key
  topic_id = azurerm_servicebus_topic.topic[each.value.topic_key].id

  max_delivery_count                   = each.value.max_delivery_count
  dead_lettering_on_message_expiration = each.value.dead_lettering_on_message_expiration
  default_message_ttl                  = each.value.default_message_ttl
  lock_duration                        = each.value.lock_duration
}

resource "azurerm_role_assignment" "subscription" {
  for_each             = local.subscription_role_assignments_flat
  scope                = azurerm_servicebus_subscription.subscription["${each.value.topic_key}|${each.value.subscription_key}"].id
  role_definition_name = each.value.role_name
  principal_id         = each.value.object_id
}
