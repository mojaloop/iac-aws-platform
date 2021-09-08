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

variable "helm_mysql_mcm_version" {
  description = "Chart version for MySQL used by MCM"
}

variable "region" {
  description = "AWS region"
}

variable "client" {
  description = "Name of client"
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

variable "helm_mcm_connection_manager_version" {
  description = "Helm char version to install MCM"
}

variable "helm_nginx_version" {
  description = "Nginx version used by the ingress controller"
}

variable "helm_mojaloop_version" {
  description = "Mojaloop version to install via Helm"
}

variable "helm_mojaloop_release_name" {
  description = "Mojaloop helm release name"
  default = "mojaloop"
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

variable "onboarding_secret_name_prefix" {
  default = "secret/onboarding"
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

variable "private_registry_pw" {
  description = "pw for private registry"
  type        = string
  default     = "override this for private image repo usage"
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

variable "ghcr_private_registry_pw" {
  description = "pw for private registry"
  type        = string
  default     = "override this for private image repo usage"
}

variable "ghcr_private_registry_user" {
  description = "pw for private registry"
  type        = string
  default     = "override this for private image repo usage"
}

variable "ghcr_private_registry_reg" {
  description = "pw for private registry"
  type        = string
  default     = "override this for private image repo usage"
}

variable "private_helm_repo_read_user" {
  description = "user for private helm repo"
  type        = string
  default     = ""
}

variable "private_helm_repo_read_key" {
  description = "key for private helm repo"
  type        = string
  default     = ""
}

variable "helm_finance_portal_version" {
  description = "version for finance portal helm chart and image tag"
  type        = string
  default     = ""
}
variable "finance_portal_users" {
  description = "finance portal users list"
  type = list(object({
    username  = string
    roles     = list(string)
  }))
  default = []
}

variable "alias_oracle_name" {
  description = "host name for alias oracle"
  type        = string
  default     = "alias-oracle"
}


variable "helm_alias_oracle_version" {
  description = "helm version for alias oracle"
  type        = string
}

variable "helm_mojaloop_reporting_service_version" {
  description = "helm version for reporting service"
  type        = string
}

variable "use_alias_oracle_endpoint" {
  description = "use alias oracle instead of internal"
  type        = string
  default     = "no"
}

variable "mfi_account_oracle_name" {
  description = "host name for MFI account oracle"
  type        = string
  default     = "mfi-account-oracle"
}

variable "helm_mfi_account_oracle_version" {
  description = "helm version for MFI account oracle"
  type        = string
}

variable "use_mfi_account_oracle_endpoint" {
  description = "use MFI account oracle instead of internal"
  type        = string
  default     = "no"
}