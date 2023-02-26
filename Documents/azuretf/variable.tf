variable "location" {
  type        = string
  description = "The location for the deployment"
  default     = "Central India"
}

variable "rsgname" {
  type        = string
  description = "Resource group name"
  default     = "Azure-terraform1"
}


variable "vnet" {
  default = "vnet-network"
}

variable "address_space" {
  default = "10.0.0.0/16"
}

variable "subnet_prefix" {
  #type = list(string)
  
  default = [
    {
      ip   = "10.0.1.0/24"
      name = "subnet-1"
    },
    {
      ip   = "10.0.2.0/24"
      name = "subnet-2"
    },
    {
      ip   = "10.0.3.0/24"
      name = "subnet-3"
    },
    {
      ip   = "10.0.4.0/24"
      name = "subnet-4"
    },
    {
      ip   = "10.0.5.0/24"
      name = "subnet-5"
    },
    {
      ip   = "10.0.6.0/24"
      name = "subnet-6"
    }
  ]
}


variable "virtual_machine" {
  default = "VM"
}

variable "VM_login_username" {
  type        = string
  description = "VM Server login username in Azure"
  default     = "admin"
}

variable "VM_login_password" {
  type        = string
  description = "VM Server password in Azure"
  default     = "Admin@54321"
}

variable "ni" {
  default = "net_interface"

}


variable "cluster_name" {
  type        = string
  description = "AKS name in Azure"
  default     = "kubcus555"
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version"
  default     = "1.25.4"
}

variable "system_node_count" {
  type        = number
  description = "Number of AKS worker nodes"
  default     = 1
}

variable "acr_name" {
  type        = string
  description = "ACR name"
  default     = "chinustorage"
}

variable "sql_server_name" {
  type        = string
  description = "SQL Server instance name in Azure"
  default     = "serverchinu"
}

variable "sql_database_name" {
  type        = string
  description = "SQL Database name in Azure"
  default     = "chinudb"
}

variable "sql_admin_login" {
  type        = string
  description = "SQL Server login name in Azure"
  default     = "chinu"
}

variable "sql_admin_password" {
  type        = string
  description = "SQL Server password name in Azure"
  default     = "Chiranjeeb@54321"
}

variable "public_ip_name" {
  type        = string
  description = "Public IP name in Azure"
  default     = "192.169.0.0"
}


variable "storage_account_name" {
  type        = string
  description = "Storage Account name in Azure"
  default     = "tfstorage0135"
}

variable "storage_container_name" {
  type        = string
  description = "Storage Container name in Azure"
  default     = "stgcntdash1"
}

variable "VMSS_login_username" {
  type        = string
  description = "VMSS Server login username in Azure"
  default     = "admin"
}

variable "VMSS_login_password" {
  type        = string
  description = "VMSS Server password in Azure"
  default     = "Admin@54321"
}

