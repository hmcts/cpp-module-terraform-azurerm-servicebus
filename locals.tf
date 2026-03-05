locals {
  premium_sku_name                       = "Premium"
  standard_sku_name                      = "Standard"
  premium_capacity                       = var.sku == "Premium" ? (contains([1, 2, 4], var.capacity) ? var.capacity : 1) : null
  effective_premium_messaging_partitions = var.sku == "Premium" ? coalesce(var.premium_messaging_partitions, var.capacity) : null

  post_private_endpoint_sleep_duration = "30s"

  queues_map = coalesce(var.queues, {})
  topics_map = coalesce(var.topics, {})

  subscriptions_flat = merge(flatten([
    for topic_key, topic in local.topics_map : [
      for sub_key, sub in coalesce(try(topic.subscriptions, null), {}) : {
        "${topic_key}|${sub_key}" = {
          topic_key                            = topic_key
          subscription_key                     = sub_key
          max_delivery_count                   = try(sub.max_delivery_count, 10)
          dead_lettering_on_message_expiration = try(sub.dead_lettering_on_message_expiration, false)
          default_message_ttl                  = try(sub.default_message_ttl, null)
          lock_duration                        = try(sub.lock_duration, null)
          role_assignments                     = coalesce(try(sub.role_assignments, null), [])
        }
      }
    ]
  ])...)

  queue_role_assignments_flat = merge(flatten([
    for qname, q in local.queues_map : [
      for idx, ra in coalesce(try(q.role_assignments, null), []) : {
        "${qname}|${idx}|${ra.role_name}|${ra.object_id}" = {
          queue_name = qname
          role_name  = ra.role_name
          object_id  = ra.object_id
        }
      }
    ]
  ])...)

  topic_role_assignments_flat = merge(flatten([
    for tname, t in local.topics_map : [
      for idx, ra in coalesce(try(t.role_assignments, null), []) : {
        "${tname}|${idx}|${ra.role_name}|${ra.object_id}" = {
          topic_name = tname
          role_name  = ra.role_name
          object_id  = ra.object_id
        }
      }
    ]
  ])...)

  subscription_role_assignments_flat = merge(flatten([
    for sid, s in local.subscriptions_flat : [
      for idx, ra in s.role_assignments : {
        "${sid}|${idx}|${ra.role_name}|${ra.object_id}" = {
          topic_key        = s.topic_key
          subscription_key = s.subscription_key
          role_name        = ra.role_name
          object_id        = ra.object_id
        }
      }
    ]
  ])...)
}
