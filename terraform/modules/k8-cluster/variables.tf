variable "environment" {
  description = "Environment name"
}

variable "name" {
  description = "VPC name"
}

variable "stage" {
  description = "VPC stage"
}

variable "kube_master_ebs_optimized" {
  description = "use ebs enhacements"
  default = false
}

variable "kube_worker_ebs_optimized" {
  description = "use ebs enhacements"
  default = false
}

variable "kube_master_num" {
  description = "Number of Kubernetes Master"
}

variable "kube_worker_num" {
  description = "Number of Kubernetes Workers"
}
variable "kube_worker_size" {
  description = "Size of Kubernetes Workers"
}

variable "kube_master_size" {
  description = "Size of Kubernetes Masters"
}

variable "haproxy_size" {
  description = "Size of HAproxy"
  default     = "t2.small"
}

variable "haproxy_enabled" {
  description = "Enable or disable the creation of haproxy"
  default     = true
}

variable "aws_ami" {
  description = "image ami"
}

variable "availability_zone" {
  description = "availability_zone"
}

variable "subnet_id" {
  description = "Subnet id"
}

variable "security_group_ids" {
  description = "security groups ids"
}

variable "ssh_key_name" {
  description = "ssh key name"
}

variable "master_root_volume_size" {
  description = "size of the root volume for master servers"
  default = 15
}

variable "workers_root_volume_size" {
  description = "size of the root volume for workers servers"
  default = 15
}

variable "gluster_volume_size" {
  description = "size of the volume for gluster"
  default = 40
}

variable "gluster_device_name" {
  description = "device name for gluster"
  default = "/dev/sdh"
}

variable "default_tags" {
  description = "Default tags"
  type        = map(string)
}

variable "inventory_file" {
  description = "Where to store the generated inventory file for mojaloop k8 cluster"
}

variable "haproxy_aliases" {
  description = "aliases for the haproxy server"
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

variable "kubemaster_iam_profile" {
  description = "IAM profile for k8 masters"
}

variable "kubeworker_iam_profile" {
  description = "IAM profile for k8 workers"
}
