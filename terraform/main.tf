
resource "azurerm_kubernetes_cluster" "dp-voting-app" { # kubernetes cluster
  name = "dp-voting-app"
  location = var.resource_group_location
  resource_group_name = var.resource_group_name
  dns_prefix = "dp-example1"
  sku_tier = "Free" # AKS pricing.

  default_node_pool {
    name = "default"
    node_count = var.node_count
    vm_size = "Standard_D2_V2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    owner = "dp"
    mode = "tf"
  }

  network_profile {
    network_plugin = "kubenet"
    load_balancer_sku = "standard"
  }
  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.logging.id   # enable logging
  }

  depends_on = [  # k8 cluster depends on creation of log analytics workspace
    azurerm_log_analytics_workspace.logging 
    ]
}




resource "azurerm_log_analytics_workspace" "logging" {  # log analytics workspace
  name                = "dp-log-analytics-workspace"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags = {
    owner = "dp"
    mode = "tf"
  }
}
