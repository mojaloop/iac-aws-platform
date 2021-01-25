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

variable "tenant" {
  description = "Tenant name. In lower case, spaces replaced with '-'"
  type        = string
}

variable "environment" {
  description = "Environment Name"
  type        = string
}

variable "name" {
  description = "VPC name"
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
variable "mojaloop_kube_master_num" {
  description = "Number of Kubernetes Master Nodes for mojaloop k8"
  type        = number
  default     = 3
}

variable "mojaloop_kube_master_size" {
  description = "Instance size of Kube Master Nodes for mojaloop k8"
  type        = string
  default     = "t2.medium"
}

variable "mojaloop_kube_worker_num" {
  description = "Number of Kubernetes Worker Nodes for mojaloop k8"
  type        = number
  default     = 3
}

variable "mojaloop_kube_worker_size" {
  description = "Instance size of Kubernetes Worker Nodes for mojaloop k8"
  type        = string
  default     = "m5.large"
}


variable "gateway_kube_master_num" {
  description = "Number of Kubernetes Master Nodes for mojaloop k8"
  type        = number
  default     = 3
}

variable "gateway_kube_worker_num" {
  description = "Number of Kubernetes Worker Nodes for mojaloop k8"
  type        = number
  default     = 3
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

variable "add-ons_kube_master_num" {
  description = "Number of Kubernetes Master Nodes for add-ons k8"
  type        = number
  default     = 3
}

variable "add-ons_kube_worker_num" {
  description = "Number of Kubernetes Master Nodes for add-ons k8"
  type        = number
  default     = 3
}

variable "add-ons_kube_master_size" {
  description = "Instance size of Kube Master Nodes for add-ons k8"
  type        = string
  default     = "t2.medium"
}

variable "add-ons_kube_worker_size" {
  description = "Instance size of Kubernetes Worker Nodes for add-ons k8"
  type        = string
  default     = "m5.large"
}

variable "support-services_kube_master_num" {
  description = "Number of Kubernetes Master Nodes for support-services k8"
  type        = number
  default     = 3
}

variable "support-services_kube_worker_num" {
  description = "Number of Kubernetes Master Nodes for support-services k8"
  type        = number
  default     = 3
}

variable "support-services_kube_master_size" {
  description = "Instance size of Kube Master Nodes for support-services k8"
  type        = string
  default     = "t2.medium"
}

variable "support-services_kube_worker_size" {
  description = "Instance size of Kubernetes Worker Nodes for support-services k8"
  type        = string
  default     = "m5.large"
}

variable "default_tags" {
  description = "Default tags for all resources"
  type        = map(string)
}

variable "inventory_file_mojaloop" {
  description = "Where to store the generated inventory file for mojaloop k8 cluster"
  type        = string
  default     = "../kubespray/inventory/hosts-mojaloop"
}

variable "inventory_file_gateway" {
  description = "Where to store the generated inventory file for gateway k8 cluster"
  type        = string
  default     = "../kubespray/inventory/hosts-gateway"
}

variable "inventory_file_add-ons" {
  description = "Where to store the generated inventory file for add-ons k8 cluster"
  type        = string
  default     = "../kubespray/inventory/hosts-add-ons"
}

variable "inventory_file_support-services" {
  description = "Where to store the generated inventory file for support-services k8 cluster"
  type        = string
  default     = "../kubespray/inventory/hosts-support-services"
}

variable "k8-balancer-mojaloop-aliases" {
  description = "List of Mojaloop service names for HAProxy to alias"
  type        = list(string)
  default = [
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
    "finance-portal"
  ]
}

variable "k8-balancer-gateway-aliases" {
  description = "List of gateway services for HAProxy to alias"
  type        = list(string)
  default = [
    "k8-api-gateway-lb",
    "wso2-api-lb"
  ]
}

variable "k8-balancer-add-ons-aliases" {
  description = "List of add-ons services for HAProxy to alias"
  type        = list(string)
  default = [
    "k8-api-add-ons-lb",
  ]
}

variable "k8-balancer-support-services-aliases" {
  description = "List of support-services services for HAProxy to alias"
  type        = list(string)
  default = [
    "k8-api-support-services-lb",
  ]
}

variable "wso2-mysql-host" {
  description = "Hostname of MySQL DB for WSO2"
  type        = string
  default     = "mysql-wso2.mysql-wso2.svc.cluster.local"
}

variable "wso2-mysql-port" {
  description = "WSO2 MySQL DB port"
  type        = number
  default     = 3306
}

variable "wso2-mysql-user" {
  description = "WSO2 MySQL DB user"
  type        = string
  default     = "root"
}

variable "wso2-mysql-password" {
  description = "WSO2 MySQL DB password"
  type        = string
  default     = "123soleil"
}

variable "wso2-mysql-root-password" {
  description = "WSO2 MySQL DB root password"
  type        = string
  default     = "123soleil"
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
variable "prometheus-gateway-name" {
  description = "Hostname to use with prometheus in gateway"
  type        = string
  default     = "prometheus-gateway"
}
variable "prometheus-mojaloop-name" {
  description = "Hostname to use with prometheus in mojaloop"
  type        = string
  default     = "prometheus-mojaloop"
}
variable "prometheus-add-ons-name" {
  description = "Hostname to use with prometheus in add-ons"
  type        = string
  default     = "prometheus-add-ons"
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
variable "pm4ml-name" {
  description = "Hostname to use with pm4ml in add-ons"
  type        = string
  default     = "pm4ml"
}
