variable "client" {
  description = "Name of client"
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

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "helm_mojaloop_version" {
  description = "Mojaloop version to install via Helm"
}

variable "helm_mojaloop_release_name" {
  description = "Mojaloop helm release name"
  default = "mojaloop"
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

variable "private_registry_pw" {
  description = "pw for private registry"
  type        = string
  default     = "override this for private image repo usage"
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

variable "helm_mojaloop_repo" {
  description = "repo for mojaloop charts"
  type        = string
  default     = "https://mojaloop.github.io/helm/repo"
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

variable "mfi_p2p_oracle_name" {
  description = "host name for MFI p2p oracle"
  type        = string
  default     = "mfi-p2p-oracle"
}

variable "helm_mfi_p2p_oracle_version" {
  description = "helm version for MFI p2p oracle"
  type        = string
}

variable "use_mfi_p2p_oracle_endpoint" {
  description = "use MFI p2p oracle instead of internal"
  type        = string
  default     = "no"
}

variable "internal_ttk_enabled" {
  description = "whether internal ttk instance is enabled or not"
  default = true
}

variable "ttk_test_currency1" {
  description = "Test currency for TTK GP tests"
  type        = string
  default     = "EUR"
}

variable "ttk_test_currency2" {
  description = "Test currency2 for TTK GP tests"
  type        = string
  default     = "GBP"
}

variable "ttk_test_currency3" {
  description = "Test cgs currency for TTK GP tests"
  type        = string
  default     = "CAD"
}

variable "internal_sim_enabled" {
  description = "whether internal mojaloop simulators ar enabled or not"
  default = true
}

variable "bofapi_name" {
  description = "host name for MFI account oracle"
  type        = string
  default     = "bofapi"
}

variable "bofportal_name" {
  description = "host name for BOF portal"
  type        = string
  default     = "bofportal"
}

variable "boftransfersui_name" {
  description = "host name for BOF transfers UI"
  type        = string
  default     = "boftransfersui"
}

variable "bofsettlementsui_name" {
  description = "host name for BOF settlements UI"
  type        = string
  default     = "bofsettlementsui"
}

variable "bofpositionsui_name" {
  description = "host name for BOF positions UI"
  type        = string
  default     = "bofpositionsui"
}

variable "bofiamui_name" {
  description = "host name for BOF IAM UI"
  type        = string
  default     = "bofiamui"
}

variable "bizops_portal_users" {
  description = "bizops portal users list"
  type = list(object({
    username  = string
    email     = string
  }))
  default = []
}

variable "bizops_mojaloop_roles" {
  description = "bizops mojaloop roles list"
  type = list(object({
    rolename  = string
    permissions     = list(string)
  }))
  default = []
}

variable "publicapi_external_whitelist" {
  description = "Whitelist for publicapi. The value is a comma separated list of CIDRs, e.g. 10.0.0.0/24,172.10.0.1."
  type = string
  default = "0.0.0.0/0"
}

variable "kubernetes_auth_path" {
  description = "vault kube auth engine path"
  type        = string
  default     = "kubernetes-gateway"
}
variable "k8s_api_version" {
  description = "kubernetes version of cluster"
  type        = string
  default     = "1.19.2"
}

variable "helm_oathkeeper_version"{
  description = "helm chart version of ory oathkeeper"
  type        = string
  default     = "0.19.6"
}

variable "helm_keto_version"{
  description = "helm chart version of ory keto"
  type        = string
  default     = "0.19.6"
}

variable "helm_kratos_version"{
  description = "helm chart version of kratos"
  type        = string
  default     = "0.14.1"
}

variable "helm_bof_version"{
  description = "helm chart version for bizops framework"
  type        = string
  default     = "1.0.0"
}

variable "storage_class_name" {
  description = "storage class name"
  type        = string
  default     = "longhorn"
}

variable "switch_jws_private_key" {
  description = "switch_jws_private_key"
  type        = string
  sensitive   = true
}

variable "bof_custom_resources_dir" {
  description = "dir to find custom resources"
  type        = string
}

variable "interop_switch_private_fqdn" {
  description = "fqdn for mojaloop ingresses"
  type        = string
}

variable "stateful_resources" {
  description = "stateful resource config data"
  type = list(object({
    enabled = bool
    resource_name     = string
    resource_namespace   = string
    resource_type = string
    logical_service_port = number
    logical_service_name = string
    external_service = object({
      external_endpoint = string
      external_credentials = string
    })
    generate_secret_name = string
    generate_secret_keys = list(string)
    generate_secret_vault_base_path = string
    generate_secret_extra_namespaces = list(string)
    local_resource = object({
      override_service_name = string
      resource_helm_repo = string
      resource_helm_chart = string
      resource_helm_chart_version = string
      resource_helm_values_ref = string
      create_resource_random_password = bool
      mysql_data = object({
        is_legacy = bool
        existing_secret = string
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
        existing_secret = string
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
        existing_secret = string
        password_secret_key = string
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

variable "third_party_enabled" {
  description = "whether third party apis are enabled or not"
  type = bool
  default = false
}

variable "bulk_enabled" {
  description = "whether bulk is enabled or not"
  type = bool
  default = false
}

variable "ttksims_enabled" {
  description = "whether ttksims are enabled or not"
  type = bool
  default = false
}

variable "quoting_service_simple_routing_mode_enabled" {
  description = "whether buquoting_service_simple_routing_mode_enabled is enabled or not"
  type = bool
  default = false
}
