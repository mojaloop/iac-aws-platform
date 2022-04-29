variable "AWS_DEFAULT_REGION" {
  description = "AWS Region"
}

//openvpn
variable "vpn_port" {
  default = "46883"
}

variable "osuser" {
  default = "ubuntu"
}

variable "client" {
  description = "Name of client. In lower case, spaces replaced with '-'"
  type        = string
}

variable "environment" {
  description = "Environment Name"
  type        = string
}

variable "use_focal_ubuntu" {
  description = "use focal or bionic"
  type = bool
  default = false
}

//AWS EC2 global Settings

variable "aws_bastion_size" {
  description = "EC2 Instance Size of Bastion Host"
  type        = string
  default     = "t2.micro"
}

variable "global_vm_size" {
  description = "EC2 Instance Size default"
  type        = string
  default     = "t2.small"
}

/*
* AWS EC2 Settings
* The number should be divisable by the number of used
* AWS Availability Zones without an remainder.
*/

variable "region" {
  description = "default region zone"
  default     = "eu-west-1"
}

variable "kube_master_num" {
  description = "Number of Kubernetes Master Nodes for mojaloop k8"
  type        = number
  default     = 3
}

variable "kube_worker_num" {
  description = "Number of Kubernetes Worker Nodes for mojaloop k8"
  type        = number
  default     = 6
}
variable "kube_worker_size" {
  description = "Instance size of Kubernetes Worker Nodes for mojaloop k8"
  type        = string
  default     = "m5.large"
}

variable "kube_master_size" {
  description = "Instance size of Kube Master Nodes for mojaloop k8"
  type        = string
  default     = "t2.medium"
}

variable "kube_worker_rootfs_size" {
  description = "ebs vol size of Kube worker Nodes for mojaloop k8 in Gi"
  type        = number
  default     = 300
}

variable "kube_master_rootfs_size" {
  description = "ebs vol size of Kube Master Nodes for mojaloop k8 in Gi"
  type        = number
  default     = 100
}


variable "inventory_file" {
  description = "Where to store the generated inventory file for gateway k8 cluster"
  type        = string
  default     = "inventory"
}

variable "custom_tags" {
  description = "Hostname to use with apm"
  type        = map(string)
  default     = {}
}
variable "route53_zone_force_destroy" {
  description = "destroy public zone on destroy of env"
  type        = bool
  default     = false
}