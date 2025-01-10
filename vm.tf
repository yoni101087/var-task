
 resource "azurerm_virtual_machine" "main" {
   name                = "jonathanfe-terraform-machine"
   resource_group_name = azurerm_resource_group.main.name
   location            = azurerm_resource_group.main.location
   vm_size             = "Standard_DS1_v2"

   identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.user.id]
  }

   network_interface_ids = [
     azurerm_network_interface.main.id,
   ]
    os_profile {
      computer_name  = "hostname"
      admin_username = "testadmin"
    }
   os_profile_linux_config {
     disable_password_authentication = true
    ssh_keys {
      key_data = var.ssh_key_data
      path     = "/home/testadmin/.ssh/authorized_keys"
    }
     
     
     
   }



   storage_os_disk {
     name              = "myosdisk"
     caching           = "ReadWrite"
     create_option     = "FromImage"
     managed_disk_type = "Standard_LRS"
   }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

 }
 



resource "azurerm_virtual_machine_extension" "vm-extension" {
  name                 = "jonathanfe"
  virtual_machine_id   = azurerm_virtual_machine.main.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.1"

  settings = <<SETTINGS
{
  "commandToExecute": "sudo bash -c 'apt update && DEBIAN_FRONTEND=noninteractive apt install -y apt-transport-https python3-pip ca-certificates curl software-properties-common && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && echo \"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" > /etc/apt/sources.list.d/docker.list && apt update && DEBIAN_FRONTEND=noninteractive apt install -y docker-ce && usermod -aG docker testadmin'"
}
SETTINGS
}







 



