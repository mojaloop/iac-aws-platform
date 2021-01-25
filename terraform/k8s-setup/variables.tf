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

variable "wso2_mysql_root_password" {
  description = "Root password for WSO2 MySQL Server"
  type        = string
  default     = "123soleil"
}

variable "wso2_mysql_password" {
  description = "User password for WSO2 MySQL Server"
  type        = string
  default     = "123soleil"
}

variable "helm_efs_provisioner_version" {
  description = "Chart version for the efs provisioner"
}

variable "helm_mysql_mcm_version" {
  description = "Chart version for MySQL used by MCM"
}

variable "region" {
  description = "AWS region"
}

variable "tenant" {
  description = "Tenant name"
  type        = string
}

# variable "subdomain" {
#   description = "Mojaloop subdomain"
# }

# variable "domain" {
#   description = "Mojaloop base domain"
# }

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "name" {
  description = "VPC name"
}

variable "helm_mcm_connection_manager_version" {
  description = "Helm char version to install MCM"
}

variable "helm_nginx_version" {
  description = "Nginx version used by the ingress controller"
}

variable "helm_mojaloop_version" {
  description = "Mojaloop version to install via Helm"
}

variable "project_root_path" {
  description = "Root path for IaC project"
}

variable "helm_apm_version" {
  description = "apm chart version to install via Helm"
}

variable "helm_fluentd_version" {
  description = "fluentd-elasticsearch chart version to install via Helm"
}

variable "helm_elasticsearch_version" {
  description = "elasticsearch chart version to install via Helm"
}

variable "helm_kibana_version" {
  description = "kibana chart version to install via Helm"
}

variable "helm_prometheus_version" {
  description = "prometheus chart version to install via Helm"
}

variable "helm_grafana_version" {
  description = "grafana chart version to install via Helm"
}

variable "helm_kafka_version" {
  description = "kafka version to install via Helm"
}

variable "helm_esp_version" {
  description = "esp chart version to install via Helm"
}

variable "whitelist_secret_name_prefix" {
  default = "secret/whitelist"
}

variable "hub_currency_code" {
  description = "currency code for the hub"
}

variable "iac_post_init_version" {
  description = "tag on iac post init repo"
  type        = string
}

variable "kafka" {
  description = "Kafka default settings"
  default = {
    retention_hours = 24
    storage_type    = "slow"
    storage_size    = "7Gi"
    mountPath       = "/opt/kafka/data"
  }
}

variable "grafana_slack_notifier_url" {
  description = "URL for slack notifier. In the form of https://hooks.slack.com/services/<VALUE>"
  type        = string
}
