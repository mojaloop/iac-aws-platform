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


variable "aws_ami" {
  description = "AMI image ID"
  type        = string
  default     = "ami-0e219142c0bee4a6e"
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

variable "haproxy_size" {
  description = "Instance size of Kube Master Nodes for mojaloop k8"
  type        = string
  default     = "t2.small"
}

variable "gw_haproxy_size" {
  description = "Instance size of Kube Master Nodes for mojaloop k8"
  type        = string
  default     = "t2.small"
}

variable "gateway_kube_master_num" {
  description = "Number of Kubernetes Master Nodes for mojaloop k8"
  type        = number
  default     = 3
}

variable "gateway_kube_worker_num" {
  description = "Number of Kubernetes Worker Nodes for mojaloop k8"
  type        = number
  default     = 6
}
variable "gateway_kube_worker_size" {
  description = "Instance size of Kubernetes Worker Nodes for mojaloop k8"
  type        = string
  default     = "m5.large"
}

variable "gateway_kube_master_size" {
  description = "Instance size of Kube Master Nodes for mojaloop k8"
  type        = string
  default     = "t2.medium"
}

variable "inventory_file_gateway" {
  description = "Where to store the generated inventory file for gateway k8 cluster"
  type        = string
  default     = "../kubespray-inventory/hosts-gateway"
}

variable "k8-balancer-gateway-aliases" {
  description = "List of gateway services for HAProxy to alias"
  type        = list(string)
  default = [
    "k8-api-gateway-lb",
    "wso2-api-lb",
    "k8-api-mojaloop-lb",
    "interop-switch",
    "account-lookup-service",
    "account-lookup-service-admin",
    "central-event-processor",
    "central-kms",
    "central-ledger-admin-transfer",
    "central-ledger-timeout",
    "central-ledger-transfer-fulfil",
    "central-ledger-transfer-get",
    "central-ledger-transfer-position",
    "central-ledger-transfer-prepare",
    "central-ledger",
    "central-settlement",
    "email-notifier",
    "ml-api-adapter-notification",
    "ml-api-adapter",
    "quoting-service",
    "moja-simulator",
    "finance-portal",
    "finance-portal-v2",
    "ttkbackend",
    "ttkfrontend",
    "mojaloop-reporting",
    "kowl"
  ]
}

variable "mcm-name" {
  description = "Hostname of Connection Manager service"
  type        = string
  default     = "mcmweb"
}

variable "iskm_hostname" {
  description = "Hostname to use with ISKM service"
  type        = string
  default     = "iskm"
}

variable "intgw_hostname" {
  description = "Hostname to use with WSO2 Internal gateway service"
  type        = string
  default     = "intgw"
}

variable "extgw_hostname" {
  description = "Hostname to use with WSO2 External gateway service"
  type        = string
  default     = "extgw"
}

variable "finance-portal-name" {
  description = "Hostname of Connection Manager service"
  type        = string
  default     = "finance-portal"
}
variable "prometheus-services-name" {
  description = "Hostname to use with prometheus in support services"
  type        = string
  default     = "prometheus-services"
}
variable "grafana-services-name" {
  description = "Hostname to use with grafana in support services"
  type        = string
  default     = "grafana"
}
variable "kibana-services-name" {
  description = "Hostname to use with kibana in support services"
  type        = string
  default     = "kibana"
}
variable "elasticsearch-services-name" {
  description = "Hostname to use with elasticsearch"
  type        = string
  default     = "elasticsearch"
}
variable "apm-services-name" {
  description = "Hostname to use with apm"
  type        = string
  default     = "apm"
}

variable "custom_tags" {
  description = "Hostname to use with apm"
  type        = map(string)
  default     = {}
}