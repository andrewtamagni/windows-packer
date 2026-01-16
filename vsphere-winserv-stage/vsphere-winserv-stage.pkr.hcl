# https://www.packer.io/docs/templates/hcl_templates/variables#type-constraints for more info.

packer {
  required_version = ">= 1.7.0"
  required_plugins {
    vsphere = {
      version = ">= 1.3.0"
      source  = "github.com/hashicorp/vsphere"
    }
  }
}

locals {
  vsphere_plugin_path = "${path.root}/plugins/packer-plugin-vsphere_v1.4.2_x5.0_linux_arm64"
}

# Variables for vSphere and Windows configuration
variable "cpu_num" {}
variable "disk_size" {}
variable "mem_size" {}
variable "vsphere_compute_cluster" {}
variable "vsphere_datastore" {}
variable "vm_disk_controller_type" {}
variable "vsphere_dc_name" {}
variable "vsphere_folder" {}
variable "vsphere_server" {}
variable "vsphere_portgroup_name" {}
variable "vsphere_user" {}
variable "vsphere_password" {}
variable "winadmin_password" {}
variable "vsphere_vm_name" {}
variable "os_iso_path" {}

# https://www.packer.io/docs/templates/hcl_templates/blocks/source

source "vsphere-iso" "vsphere-winserv-stage" {
  CPUs                 = var.cpu_num
  CPU_hot_plug         = true
  RAM                  = var.mem_size
  RAM_reserve_all      = true
  RAM_hot_plug         = true
  cluster              = var.vsphere_compute_cluster
  communicator         = "winrm"
  winrm_timeout        = "2h"
  ip_wait_timeout      = "2h"
  convert_to_template  = "false"
  datacenter           = var.vsphere_dc_name
  datastore            = var.vsphere_datastore
  disk_controller_type = [var.vm_disk_controller_type]
  firmware             = "efi-secure"
  floppy_files         = ["${path.root}/Autounattend.xml", "${path.root}/../common/scripts/setupStaticIp.ps1"]
  folder               = var.vsphere_folder
  guest_os_type        = "windows2022srvNext_64Guest"
  insecure_connection  = "true"
  iso_paths            = ["${var.os_iso_path}"]
  
  boot_wait = "3s"
  boot_command = [
    "<spacebar><spacebar>"
  ]

  network_adapters {
    network      = var.vsphere_portgroup_name
    network_card = "vmxnet3"
  }
  
  storage {
    disk_size             = var.disk_size
    disk_thin_provisioned = true
  }
  username       = var.vsphere_user
  vcenter_server = var.vsphere_server
  password       = var.vsphere_password
  vm_name        = var.vsphere_vm_name
  winrm_username = "Administrator"
  winrm_password = var.winadmin_password
}

# https://www.packer.io/docs/templates/hcl_templates/blocks/build
build {
  
  sources = ["source.vsphere-iso.vsphere-winserv-stage"]

  # Ensure hostname matches the VM name (and reboot to apply)
  provisioner "powershell" {
    elevated_user     = "Administrator"
    elevated_password = var.winadmin_password
    inline = [
      "if ((hostname) -ne \"${var.vsphere_vm_name}\") { Rename-Computer -NewName \"${var.vsphere_vm_name}\" -Force -PassThru }"
    ]
  }
  
  # Reboot after VMware updates
  provisioner "windows-restart" {
    restart_timeout = "5m"
  }
  
  # Copy a script to run updates and harden security settings
  provisioner "file" {
    source      = "../common/scripts/updateAndHarden.ps1"
    destination = "C:/Windows/Temp/updateAndHarden.ps1"
  }

  # Run the updateAndHarden.ps1 script
  provisioner "powershell" {
    elevated_user = "Administrator"
    elevated_password = var.winadmin_password
    inline = ["powershell -ExecutionPolicy Bypass -File C:/Windows/Temp/updateAndHarden.ps1"]
  }

  # Reboot after OS updates
  provisioner "windows-restart" {
    restart_timeout = "45m"
  }
}