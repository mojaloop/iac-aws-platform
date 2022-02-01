variable "helm_consul_version" {
  description = "chart version to deploy consul"
}
variable "helm_vault_version" {
  description = "chart version to deploy vault"
}
variable "aws_access_key" {
  description = "AWS Access Key to manage KMS access"
}
variable "region" {
  description = "AWS region"
}
variable "aws_secret_key" {
  description = "AWS Secret Key to manage KMS access"
}
variable "project_root_path" {
  description = "Root folder for the infrastructure code"
}
variable "kubernetes_auth_path" {
  description = "vault kube auth engine path"
  type        = string
  default     = "kubernetes-gateway"
}
variable "environment" {
  description = "Environment name"
  type        = string
}
variable "client" {
  description = "Name of client"
  type        = string
}
variable "wso2_namespace" {
  description = "Kubernetes namespace to install WSO2 into"
  type        = string
  default     = "wso2"
}
variable "cert_man_namespace" {
  description = "Kubernetes namespace to install certman into"
  type        = string
  default     = "cert-manager"
}
variable "helm_certmanager_version" {
  description = "helm certmanager version"
}

variable "external_dns_namespace" {
  description = "Kubernetes namespace to install external dns into"
  type        = string
  default     = "external-dns"
}
variable "helm_external_dns_version" {
  description = "helm external dns version"
}

variable "helm_nginx_version" {
  description = "Nginx version used by the ingress controller"
}

variable "whitelist_secret_name_prefix" {
  default = "secret/whitelist"
}

variable "onboarding_secret_name_prefix" {
  default = "secret/onboarding"
}

variable "k8s_api_version" {
  description = "kubernetes version of cluster"
  type        = string
  default     = "1.19.2"
}

variable "ebs_storage_class_name" {
  description = "storage class name"
  type        = string
  default     = "ebs"
}
variable "custom_tags" {
  description = "Hostname to use with apm"
  type        = map(string)
  default     = {}
}
variable "letsencrypt_server" {
  description = "production le server or staging"
  type        = string
  default     = "production"
}
variable "wso2_email" {
  description = "email address for wso2"
  type        = string
  default     = "cicd@modusbox.com"
}
variable "cert_man_letsencrypt_cluster_issuer_name" {
  description = "cluster issuer name for letsencrypt"
  type        = string
  default     = "letsencrypt"
}
variable "cert_man_vault_cluster_issuer_name" {
  description = "cluster issuer name for vault"
  type        = string
  default     = "vault-issuer-int"
}
variable "int_wildcard_cert_sec_name" {
  description = "letsenc wildcard sec for operations tls endpoints"
  type        = string
  default     = "int-ops-wildcard-tls"
}