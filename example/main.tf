data "azurerm_subscription" "current" {}

module "tag_set" {
  source         = "git::https://github.com/hmcts/cpp-module-terraform-azurerm-tag-generator.git?ref=main"
  namespace      = var.namespace
  application    = var.application
  costcode       = var.costcode
  owner          = var.owner
  version_number = var.version_number
  attribute      = var.attribute
  environment    = var.environment
  type           = var.type
}

resource "azurerm_resource_group" "test" {
  name     = var.resource_group_name
  location = var.location
  tags     = module.tag_set.tags
}

resource "azurerm_virtual_network" "test" {
  name                = var.vnet_name
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.0.0.0/16"]
  tags                = module.tag_set.tags
}

resource "azurerm_subnet" "test" {
  name                                          = "example-subnet"
  resource_group_name                           = azurerm_resource_group.test.name
  virtual_network_name                          = azurerm_virtual_network.test.name
  address_prefixes                              = ["10.0.1.0/24"]
  private_link_service_network_policies_enabled = false
  private_endpoint_network_policies             = "Disabled"
}

module "servicebus_namespace" {
  source = "../"

  name                          = var.name
  resource_group_name           = azurerm_resource_group.test.name
  location                      = var.location
  environment                   = var.environment
  sku                           = var.sku
  tags                          = module.tag_set.tags
  public_network_access_enabled = var.public_network_access_enabled
  private_endpoint_subnet_id    = var.public_network_access_enabled ? null : azurerm_subnet.test.id
  log_analytics_workspace_id    = var.log_analytics_workspace_id
  capacity                      = var.capacity
  cmk_key_id                    = var.cmk_key_id
  cmk_user_assigned_identity_id = var.cmk_user_assigned_identity_id
  role_assignments              = var.role_assignments
  queues                        = var.queues
  topics                        = var.topics
}
