provider "azurerm" {
  features {}
  subscription_id = "f28dfbc5-b832-4316-bca4-927f32eaf6a6"
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-aks"
  location = "East US 2"
}

resource "azurerm_container_registry" "acr" {
  name                = "mandacontainer2342423" # Must be globally unique
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "myAKSCluster"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "myaks"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
    
  }
  identity {
    type = "SystemAssigned"
  }
  acr_attach {
    acr_name = "mandacontainer2342423"
  }

}

resource "azurerm_role_assignment" "acr_pull" {
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.acr.id
}


