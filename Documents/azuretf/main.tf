terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}
provider "azurerm" {
  features {}
}

locals {
  tags = {
    Name         = "Rao sahab"
    organization = "kellton"
    Approved_by  = "owner"
  }
}
resource "azurerm_resource_group" "at" {
  name     = var.rsgname
  location = var.location
  tags     = local.tags

}

resource "azurerm_network_security_group" "subnet_nsg" {

 # name = "${azurerm_subnet.subnet[1]}-nsg"
  name = azurerm_subnet.subnet[1].name

  location = var.location

  resource_group_name = azurerm_resource_group.at.name

}

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet
  location            = azurerm_resource_group.at.location
  resource_group_name = azurerm_resource_group.at.name
  address_space       = ["${var.address_space}"]
  tags                = local.tags
}


resource "azurerm_subnet" "subnet" {
  name                 = lookup(element(var.subnet_prefix, count.index),"name")
  count                = length(var.subnet_prefix)
  resource_group_name  = azurerm_resource_group.at.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [lookup(element(var.subnet_prefix, count.index),"ip")]
  depends_on = [
    azurerm_virtual_network.vnet
  ]
}

resource "azurerm_network_interface" "ni" {
  name                = var.ni
  location            = azurerm_resource_group.at.location
  resource_group_name = azurerm_resource_group.at.name

  ip_configuration {
    name                          = "ipconf"
    subnet_id                     = azurerm_subnet.subnet[1].id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "vm" {
  name                  = var.virtual_machine
  location              = azurerm_resource_group.at.location
  resource_group_name   = azurerm_resource_group.at.name
  network_interface_ids = [azurerm_network_interface.ni.id]
  vm_size               = "Standard_DS1_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  #delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  #delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = var.VM_login_username
    admin_password = var.VM_login_password
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = local.tags
}

#creating blob storage
resource "azurerm_storage_account" "storage" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.at.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

}

resource "azurerm_storage_account_network_rules" "loc" {
  storage_account_id = azurerm_storage_account.storage.id

  default_action             = "Allow"
  ip_rules                   = ["127.0.0.1"]
  virtual_network_subnet_ids = [azurerm_subnet.subnet[1].id]
  bypass                     = ["Metrics"]
}
resource "azurerm_storage_container" "container" {
  name                 = var.storage_container_name
  storage_account_name = azurerm_storage_account.storage.name
  #container_access_type = "container" # "blob" "private"
  container_access_type = "private"
}

resource "azurerm_storage_blob" "storage_container1" {
  name                   = "tf"
  storage_account_name   = azurerm_storage_account.storage.name
  storage_container_name = azurerm_storage_container.container.name
  type                   = "Block"
  source                 = "/home/chiranjeeb.dash/Downloads/main.tf"
}


# creating kuberneties cluster

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  kubernetes_version  = var.kubernetes_version
  location            = var.location
  resource_group_name = azurerm_resource_group.at.name
  dns_prefix          = var.cluster_name

  default_node_pool {
    name       = "system"
    node_count = var.system_node_count
    vm_size    = "Standard_DS2_v2"
    type       = "VirtualMachineScaleSets"
    #availability_zones  = [1, 2, 3]
    enable_auto_scaling = false
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    load_balancer_sku = "standard"
    network_plugin    = "kubenet" # CNI
  }
}
#container_registry
resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.at.name
  location            = var.location
  sku                 = "Standard"
  admin_enabled       = false
}
#mysql server
resource "azurerm_mysql_server" "sql" {
  name                         = var.sql_server_name
  resource_group_name          = azurerm_resource_group.at.name
  location                     = azurerm_resource_group.at.location
  administrator_login          = var.sql_admin_login
  administrator_login_password = var.sql_admin_password
  ssl_enforcement_enabled      = true
  sku_name                     = "B_Gen5_2"
  storage_mb                   = 5120
  version                      = "5.7"
}

resource "azurerm_mysql_database" "main" {
  name                = var.sql_database_name
  resource_group_name = var.rsgname
  server_name         = azurerm_mysql_server.sql.name
  charset             = "utf8"
  collation           = "utf8_general_ci"
}



resource "azurerm_public_ip" "public_ip" {
  name                = var.public_ip_name
  location            = azurerm_resource_group.at.location
  resource_group_name = azurerm_resource_group.at.name
  allocation_method   = "Dynamic"

  tags = local.tags
}

// Here we are creating the Azure Load Balancer

resource "azurerm_lb" "lb_balancer" {
  name                = "lb-balancer"
  location            = azurerm_resource_group.at.location
  resource_group_name = azurerm_resource_group.at.name
  frontend_ip_configuration {
    name                 = "frontend-ip"
    public_ip_address_id = azurerm_public_ip.public_ip.id
  }

  depends_on = [
    azurerm_public_ip.public_ip
  ]
}
resource "azurerm_lb_backend_address_pool" "scalesetpool" {
  loadbalancer_id = azurerm_lb.lb_balancer.id
  name            = "scalesetpool"
  depends_on = [
    azurerm_lb.lb_balancer
  ]
}
// Here we are defining the Health Probe
resource "azurerm_lb_probe" "ProbeA" {
  #resource_group_name = azurerm_resource_group.at.name
  loadbalancer_id = azurerm_lb.lb_balancer.id
  name            = "probeA"
  port            = 80
  protocol        = "Tcp"
  depends_on = [
    azurerm_lb.lb_balancer
  ]
}
// Here we are defining the Load Balancing Rule
resource "azurerm_lb_rule" "RuleA" {
  loadbalancer_id                = azurerm_lb.lb_balancer.id
  name                           = "RuleA"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "frontend-ip"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.scalesetpool.id]
}

#vmss
resource "azurerm_linux_virtual_machine_scale_set" "replica" {
  name                = "replica-vmss"
  resource_group_name = azurerm_resource_group.at.name
  location            = azurerm_resource_group.at.location
  sku                 = "Standard_DS1_v2"
  instances           = 1
  admin_username      = var.VMSS_login_username
  admin_password      = var.VMSS_login_password
  

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "vm2"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = azurerm_subnet.subnet[1].id
    }
  }
}

#RADIS
# resource "azurerm_redis_cache" "testing" {
#   name                = "testing-redis"
#   location            = azurerm_resource_group.at.location
#   resource_group_name = azurerm_resource_group.at.name
#   capacity            = 2
#   family              = "C"
#   sku_name            = "Standard"
#   enable_non_ssl_port = false
#   minimum_tls_version = "1.2"

#   redis_configuration {
#   maxmemory_reserved = 10
#   maxmemory_delta    = 2
#   maxmemory_policy   = "allkeys-lru"
#   }
# }
