variable "region" {
  description = "AWS region"
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
variable "helm_mysql_wso2_version" {
  description = "Helm chart version to install MySQL used by wso2"
}

variable "wso2_mysql_database" {
  description = "MySQL Database name"
  type        = string
  default     = "wso2"
}

variable "wso2_namespace" {
  description = "Kubernetes namespace to install WSO2 into"
  type        = string
  default     = "wso2"
}

variable "mcm_namespace" {
  description = "Kubernetes namespace to install connection manager into"
  type        = string
  default     = "mcm"
}

variable "cert_man_namespace" {
  description = "Kubernetes namespace to install WSO2 into"
  type        = string
  default     = "cert-manager"
}

variable "wso2_mysql_host" {
  description = "MySQL hostname for WSO2"
  type        = string
}
variable "wso2_mysql_repo_version" {
  description = "MySQL database version to install WSO2 into"
  type        = string
}

variable "whitelist_mcm" {
  description = "Enable/disable MCM access"
  default     = []
}

variable "wso2_mysql_username" {
  description = "MySQL username"
  type        = string
  default     = "wso2"
}

variable "wso2_email" {
  description = "email address for wso2"
  type        = string
  default     = "cicd@modusbox.com"
}

variable "helm_efs_provisioner_version" {
  description = "Chart version for the efs provisioner"
}
variable "helm_certmanager_version" {
  description = "helm certmanager version"
}

variable "helm_nginx_version" {
  description = "Nginx version used by the ingress controller"
}

variable "mcm-name" {
  description = "Hostname of Connection Manager service"
  type        = string
  default     = "mcmweb"
}

variable "mcm-totp-issuer" {
  description = "Name to associate with Connection Manaager TOTP"
  type        = string
  default     = "HACKATHON"
}

variable "helm_mcm_connection_manager_version" {
  description = "Helm char version to install MCM"
}
variable "helm_mysql_mcm_version" {
  description = "Chart version for MySQL used by MCM"
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

variable "grafana_slack_notifier_url" {
  description = "URL for slack notifier. In the form of https://hooks.slack.com/services/<VALUE>"
  type        = string
}

variable "helm_loki_stack_version" {
  description = "helm loki-stack version"
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

variable "helm_haproxy_version" {
  description = "version of haproxy chart (mojaloop fork)"
  type        = string
  default     = "1.7.2"
}

variable "helm_oathkeeper_version"{
  description = "helm chart version of ory oathkeeper"
  type        = string
  default     = "0.21.5"
}

variable "mcm_secret_path" {
  description = "vault kv secret path for mcm use"
  type        = string
  default     = "secret/mcm"
}