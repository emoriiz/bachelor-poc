# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface
# https://registry.terraform.io/providers/hashicorp/Azurerm/latest/docs/resources/windows_virtual_machine

# Netzwerk Interface
resource "azurerm_network_interface" "vm" {
  name                = "nic-${var.location_code}-${var.vm_name}"
  location            = var.datacenter_location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.tags
}

# Virtuelle Maschine
resource "azurerm_windows_virtual_machine" "vm" {
  name                = "vm-${var.location_code}-${var.vm_name}"
  resource_group_name = var.resource_group_name
  location            = var.datacenter_location
  size           = var.vm_size
  admin_username = "azureadmin"
  admin_password = var.admin_password
  patch_mode = "AutomaticByPlatform"
  network_interface_ids = [
    azurerm_network_interface.vm.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = var.vm_sku
    version   = "latest"
  }

  tags = var.tags
}