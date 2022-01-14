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

variable "iskm_fqdn" {
  description = "FQDN of ISKM service"
  type = string
}

variable "helm_deployment" {
  description = "Kubernetes Deployment name for ISKM"
  type = string
}

variable "service_account_name" {
  description = "Service Account to run under"
  type = string
}

variable "vault_role_name" {
  description = "Role Name for Vault Access"
  type = string
}

variable "vault_secret_name" {
  description = "secret name after secret/"
  type = string
}

variable "vault_secret_file_name" {
  description = "name of file to write"
  type = string
}

variable "vault_pm4ml_wl_secret_name" {
  description = "secret name for pm4mls after secret/"
  type = string
}

variable "vault_pm4ml_wl_secret_file_name" {
  description = "name of file to write for pm4ml secrets"
  type = string
}

variable "wso2_admin_pw" {
  description = "admin password for wso2"
  type = string
}

variable "efs_storage_class_name" {
  description = "storage class name for efs"
  type = string
  default = "efs"
}

variable "wso2_iskm_helm_name" {
  description = "placeholder to force dependency"
  type = string
}

variable "ext_ingress_controller_name" {
  description = "ext_ingress_controller_name"
  type = string
  default = "nginx-ext"
}
variable "data_ext_issuer_name" {
  description = "cert man issuer name for data extgw"
  type = string
  default = "vault-issuer-int"
}
variable "int_ingress_controller_name" {
  description = "int_ingress_controller_name"
  type = string
  default = "nginx"
}