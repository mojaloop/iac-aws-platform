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

variable "wso2_mysql_repo_version" {
  description = "MySQL database version to install WSO2 into"
  type        = string
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

variable "whitelist_mcm" {
  description = "Enable/disable MCM access"
  default     = []
}

variable "wso2_email" {
  description = "email address for wso2"
  type        = string
  default     = "cicd@modusbox.com"
}

variable "mcm_name" {
  description = "Hostname of Connection Manager service"
  type        = string
  default     = "mcm"
}

variable "mcm-totp-issuer" {
  description = "Name to associate with Connection Manaager TOTP"
  type        = string
  default     = "HACKATHON"
}

variable "helm_mcm_connection_manager_version" {
  description = "Helm char version to install MCM"
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

variable "storage_class_name" {
  description = "storage class name"
  type        = string
  default     = "longhorn"
}

variable "grafana_slack_notifier_url" {
  description = "URL for slack notifier. In the form of https://hooks.slack.com/services/<VALUE>"
  type        = string
}

variable "helm_loki_stack_version" {
  description = "helm loki-stack version"
}

variable "cert_man_vault_cluster_issuer_name" {
  description = "cluster issuer name for vault"
  type        = string
  default     = "vault-issuer-root"
}

variable "helm_haproxy_version" {
  description = "version of haproxy chart (mojaloop fork)"
  type        = string
  default     = "1.7.2"
}

variable "mcm_secret_path" {
  description = "vault kv secret path for mcm use"
  type        = string
  default     = "secret/mcm"
}
variable "vault-certman-secretname" {
  description = "secret name to create for tls offloading via certmanager"
  type = string
  default = "tokenextgw-tls-ext"
}

variable "grafana_external_access" {
  description = "grafana is external (true) or internal (false)"
  type = bool
  default = false
}

variable "grafana_external_whitelist" {
  description = "whitelist for grafana when exposed externally"
  type = string
  default = "0.0.0.0/0"
}

variable "iskm_helm_chart_version" {
  description = "version of wso2 iskm helm chart to deploy"
  type        = string
}
variable "extgw_helm_chart_version" {
  description = "version of wso2 extgw helm chart to deploy"
  type        = string
}
variable "intgw_helm_chart_version" {
  description = "version of wso2 intgw helm chart to deploy"
  type        = string
}

variable "kubeconfig_location" {
  description = "file location of kubeconfig"
  type = string
}

variable "gitlab_hostname" {
  description = "gitlab_hostname"
  type        = string
}

variable "public_subdomain" {
  description = "public_subdomain"
  type        = string
}

variable "private_subdomain" {
  description = "private_subdomain"
  type        = string
}

variable "internal_load_balancer_dns" {
  description = "internal_load_balancer_dns"
  type        = string
}

variable "k8s_worker_nodes_private_ip" {
  description = "k8s_worker_nodes_private_ip"
  type        = list(string)
}

variable "vault_addr" {
  description = "vault_addr"
  type        = string
}

variable "stateful_resources" {
  description = "stateful resource config data"
  type = list(object({
    enabled = bool
    resource_name     = string
    resource_namespace   = string
    logical_service_port = number
    logical_service_name = string
    vault_credential_paths = object({
      pw_data = object({
        user_password_path_prefix = string
        root_password_path_prefix = string
      })
    }) 
    external_service = object({
      external_endpoint = string
      external_credentials = string
    })
    local_resource = object({
      override_service_name = string
      resource_helm_repo = string
      resource_helm_chart = string
      resource_helm_chart_version = string
      resource_helm_values_ref = string
      create_resource_random_password = bool
      mysql_data = object({
        root_password = string
        user = string
        user_password = string
        database_name = string
        storage_size = string
        architecture = string
        replica_count = number
        service_port = number
      })
      mongodb_data = object({
        root_password = string
        user = string
        user_password = string
        database_name = string
        storage_size = string
        service_port = number
      })
      kafka_data = object({
        storage_size = string
        service_port = number
      })
      redis_data = object({
        user_password = string
        user = string
        storage_size = string
        architecture = string
        replica_count = number
        service_port = number
      })
    }) 
  }))
  default = []
}
