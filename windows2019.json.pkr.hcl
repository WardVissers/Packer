﻿// https://www.packer.io/plugins/builders/vmware/iso

// Plugins
// Windows Update plug-in https://github.com/rgl/packer-plugin-windows-update
// https://github.com/hashicorp/packer-plugin-vmware/releases

packer {
  required_version = ">= 1.8.0"
  required_plugins {
    vmware = {
      version = ">= 1.0.6"
      source  = "github.com/hashicorp/vmware"
    }
  }

  required_plugins {
    windows-update = {
      version = ">= 0.14.1"
      source  = "github.com/rgl/windows-update"
    }
  }
}


variable "cpu_num" {
  type    = string
  default = "2"
}

variable "disk_size" {
  type    = string
  default = "61440"
}

variable "mem_size" {
  type    = string
  default = "4096"
}

variable "os_iso_path" {
  type    = string
  default = ""
}

variable "vmtools_iso_path" {
  type    = string
  default = ""
}

variable "vsphere_compute_cluster" {
  type    = string
  default = ""
}

variable "vsphere_datastore" {
  type    = string
  default = ""
}

variable "vsphere_dc_name" {
  type    = string
  default = ""
}

variable "vsphere_folder" {
  type    = string
  default = ""
}

variable "vsphere_host" {
  type    = string
  default = ""
}

variable "vsphere_password" {
  type      = string
  default   = ""
  sensitive = true
}

variable "vsphere_portgroup_name" {
  type    = string
  default = ""
}

variable "vsphere_server" {
  type    = string
  default = ""
}

variable "vsphere_template_name" {
  type    = string
  default = ""
}

variable "vsphere_user" {
  type    = string
  default = ""
}

variable "winadmin_password" {
  type      = string
  default   = ""
  sensitive = true
}

variable "vm_disk_controller_type" {
  type        = list(string)
  description = "The virtual disk controller types in sequence. (e.g. 'pvscsi')"
  default     = ["nvme"]
}

#Source block
source "vsphere-iso" "autogenerated_1" {
  CPUs                 = "${var.cpu_num}"
  RAM                  = "${var.mem_size}"
  RAM_reserve_all      = false
  cluster              = "${var.vsphere_compute_cluster}"
  communicator         = "winrm"
  convert_to_template  = true
  datacenter           = "${var.vsphere_dc_name}"
  datastore            = "${var.vsphere_datastore}"
  disk_controller_type = "${var.vm_disk_controller_type}"
  firmware             = "efi-secure"
  ip_wait_timeout      = "3600s"
  floppy_files         = ["setup/win19/efi/autounattend.xml","setup/drivers","setup/begin.ps1","setup/install-vmtools.ps1","setup/enable-winrm.ps1","setup/Server_ChangeCDRomDriveLetter.ps1","setup/Server_Disable_IPv6_NetBios.ps1","setup/Server_Print_Spooler_Disable.ps1","setup/disable-autolog.ps1"]
  folder               = "${var.vsphere_folder}"
  guest_os_type        = "windows2019srv_64Guest"
  host                 = "${var.vsphere_host}"
  insecure_connection  = "true"
  iso_paths            = ["${var.os_iso_path}"]
  
  boot_wait = "3s"
  boot_command = ["<spacebar><spacebar>"]
  
  network_adapters {
    network      = "${var.vsphere_portgroup_name}"
    network_card = "vmxnet3"
  }
  password = "${var.vsphere_password}"
  storage {
    disk_size             = "${var.disk_size}"
    disk_thin_provisioned = true
  }
  username       = "${var.vsphere_user}"
  vcenter_server = "${var.vsphere_server}"
  vm_name        = "${var.vsphere_template_name}"
  winrm_password = "${var.winadmin_password}"
  winrm_username = "Administrator"
}

#Build block
build {
  sources = ["source.vsphere-iso.autogenerated_1"]

  provisioner "powershell" {
     script   = "./setup/Server_ChangeCDRomDriveLetter.ps1"
  }

  provisioner "powershell" {
    script   = "./setup/Server_Disable_IPv6_NetBios.ps1"
  }

  provisioner "powershell" {
    script   = "./setup/Server_Print_Spooler_Disable.ps1"
  }

  provisioner "powershell" {
    script   = "./setup/disable-autolog.ps1"
  }
  
  provisioner "file" {
  source = "./setup/basic/"
  destination = "C:\\Temp"
 }

  provisioner "windows-update" {
    filters = [
      "exclude:$_.Title -like '*VMware*'",
      "include:$true"
    ]
  }

}