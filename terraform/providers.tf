terraform {
  required_providers {
    # Duncan Mac-Vicar P's libvirt provider
    libvirt = {
      source = "dmacvicar/libvirt"
      version = "0.6.3"
    }

    # Nick Bering's Ansible provider
    ansible = {
      source  = "nbering/ansible"
      version = ">= 1.0.4"
    }

    # Hashicorp's AWS provider
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.33"
    }

    # Hashicorp's Azure RM (ARM) provider
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.52.0"
    }
  }
}
