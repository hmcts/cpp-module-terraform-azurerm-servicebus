resource_group_name           = "rg-lab-cpp-sbterratest"
name                          = "sb-lab-cpp-trtest"
vnet_name                     = "vnet-lab-cpp-sbterratest"
location                      = "uksouth"
namespace                     = "cpp"
costcode                      = "terratest"
attribute                     = ""
owner                         = "EI"
environment                   = "nonlive"
application                   = "test"
type                          = "servicebus"
sku                           = "Standard"
public_network_access_enabled = true

queues = {
  payments = {
    max_delivery_count                   = 10
    dead_lettering_on_message_expiration = true
    role_assignments                     = []
  }
  fraudalerts = {
    max_delivery_count                   = 5
    dead_lettering_on_message_expiration = false
    role_assignments                     = []
  }
}

topics = {
  orderevents = {
    role_assignments = []
    subscriptions = {
      accounting = {
        max_delivery_count                   = 10
        dead_lettering_on_message_expiration = false
        role_assignments                     = []
      }
      audit = {
        max_delivery_count                   = 10
        dead_lettering_on_message_expiration = false
        role_assignments                     = []
      }
    }
  }
  customerevents = {
    role_assignments = []
    subscriptions = {
      notifications = {
        max_delivery_count                   = 5
        dead_lettering_on_message_expiration = false
        role_assignments                     = []
      }
    }
  }
}
