variable "kubeconfig" {
  description = "Path to kubernetes config file"
  type = string
}

variable "namespace" {
  description = "Kubernetes Namespace to deploy ConfigMaps and Secrets"
  type = string
  default = "wso2"
}

variable "contact_email" {
  description = "Email address to associate with Certs"
  type = string
}

variable "hostname" {
  description = "Hostname for WSO2 service"
  type = string
  default = "intgw"
}

variable "public_domain_name" {
  description = "Domain name for Internal GW service"
  type = string
}

variable "root_certificate" {
  description = "ROOT CA used to sign service certificate"
  type = string
}

variable "root_private_key" {
  description = "Private key that goes with root certificate"
  type = string
}

variable "db_host" {
  description = "Hostname of DB service"
  type = string
  default = "mysql-wso2.mysql-wso2.svc.cluster.local"
}

variable "db_port" {
  description = "Port number used to acess DB service"
  type = number
  default = 3306
}

variable "db_user" {
  description = "User name used to access DB service"
  type = string
  default = "wso2"
}

variable "db_password" {
  description = "User password ised to access DB service"
  type = string
}

variable "keystore_password" {
  description = "JKS password"
  type = string
}

variable "jws_password" {
  description = "Mojaloop JWS password"
  type = string
}

variable "iskm_fqdn" {
  description = "FQDN of ISKM service"
  type = string
}

variable "wso2_admin_pw" {
  description = "admin password for wso2"
  type = string
}

variable "int_ingress_controller_name" {
  description = "ingress controller ref"
  type = string
  default = "nginx"
}

variable "storage_class_name" {
  description = "storage class name"
  type        = string
  default     = "longhorn"
}
variable "helm_chart_version" {
  description = "version of helm chart to deploy"
  type        = string
}