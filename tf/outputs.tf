resource "local_file" "AnsibleInventory" { 
  content = templatefile("${path.root}/../playbooks/templates/inventory.tmpl",
   {
      jumpbox-pip       = azurerm_public_ip.jumpbox-pip.ip_address
      jumpbox-user      = azurerm_linux_virtual_machine.jumpbox.admin_username
      scheduler-ip      = azurerm_network_interface.scheduler-nic.private_ip_address
      scheduler-user    = azurerm_linux_virtual_machine.scheduler.admin_username
      ondemand-fqdn     = azurerm_public_ip.ondemand-pip.fqdn
      ondemand-ip       = azurerm_network_interface.ondemand-nic.private_ip_address
      ondemand-user     = azurerm_linux_virtual_machine.ondemand.admin_username
      ccportal-ip       = azurerm_network_interface.ccportal-nic.private_ip_address
      ad-ip             = azurerm_network_interface.ad-nic.private_ip_address
      ad-passwd         = azurerm_windows_virtual_machine.ad.admin_password
      anf-home-ip       = element(azurerm_netapp_volume.home.mount_ip_addresses, 0)
      anf-home-path     = azurerm_netapp_volume.home.volume_path
      admin-username    = var.admin_username
      ad_join_password  = random_password.password.result
    }
  )
  filename = "${path.root}/../playbooks/inventory"
}

resource "local_file" "global_variables" {
  sensitive_content = templatefile("${path.root}/../playbooks/templates/global_variables.tmpl",
    {
      admin_username = var.admin_username
      ssh_public_key = tls_private_key.internal.public_key_openssh
      cc_password    = azurerm_windows_virtual_machine.ad.admin_password
      cc_storage     = azurerm_storage_account.deployhpc.name
      region         = var.location
      resource_group = var.resource_group
    }
  )
  filename = "${path.root}/../playbooks/group_vars/all.yml"

}

resource "local_file" "connect_script" {
  sensitive_content = templatefile("${path.root}/../playbooks/templates/connect.tmpl",
    {
      jumpbox-pip       = azurerm_public_ip.jumpbox-pip.ip_address,
      jumpbox-user      = azurerm_linux_virtual_machine.jumpbox.admin_username,
    }
  )
  filename = "${path.root}/../bin/connect"
  file_permission = 0755
}

resource "local_file" "packer" {
  content = templatefile("${path.root}/../packer/templates/options.json.tmpl",
    {
      subscription_id = data.azurerm_subscription.primary.subscription_id
      resource_group  = var.resource_group
    }
  )
  filename = "${path.module}/../packer/options.json"
}


output "ondemand_fqdn" {
  value = azurerm_public_ip.ondemand-pip.fqdn
}
