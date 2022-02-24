variable "environment" {
  description = "Environment name"
}

variable "tenant" {
  description = "Tenant name"
}

variable "name" {
  description = "cluster name"
}

variable "default_tags" {
  description = "Default tags"
  type        = map(string)
}

variable "inventory_file" {
  description = "Where to store the generated inventory file for mojaloop k8 cluster"
}

variable "route53_private_zone_id" {
  description = "main private DNS zone id"
}
variable "route53_private_zone_name" {
  description = "main private DNS zone name"
}

variable "route53_public_zone_id" {
  description = "main Public DNS zone id"
}

variable "route53_public_zone_name" {
  description = "main public DNS zone name"
}

variable "master_kube_ec2_config" {
  description = "config for master ec2"
  type = list(object({
    subnet_id     = string
    availability_zone   = string
    ec2_ref = string
    aws_ami = string
    ec2_size = string
    ebs_optimized = bool
    security_group_ids = list(string)
    ssh_key_name = string
    iam_profile = string
    root_volume_size = number
    }))
  default = []
}

variable "worker_kube_ec2_config" {
  description = "config for master ec2"
  type = list(object({
    subnet_id     = string
    availability_zone   = string
    ec2_ref = string
    aws_ami = string
    ec2_size = string
    ebs_optimized = bool
    security_group_ids = list(string)
    ssh_key_name = string
    iam_profile = string
    root_volume_size = number
    }))
  default = []
}