variable "environment" {
  description = "Environment name"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "client" {
  description = "Client name"
  type        = string
}

variable "hub_account_names" {
  description = "other non sim account names. this will create accounts and whitelist entries"
  type        = list(string)
  default     = ["noresponsepayeefsp"]
}

variable "hub_account_cidr_blocks" {
  description = "hubaccount CIDR Block"
  type        = list(string)
  default     = ["10.0.0.0/8"]
}

variable "hub_currency_code" {
  description = "currency code for the hub"
  type        = string
}

variable "iac_post_init_version" {
  description = "tag on iac post init repo"
  type        = string
}

variable "helm_mojaloop_version" {
  description = "Mojaloop version to install via Helm"
}

variable "helm_mojaloop_release_name" {
  description = "Mojaloop helm release name"
  default = "mojaloop"
}

variable "private_registry_pw" {
  description = "pw for private registry"
  type        = string
  default     = "override this for private image repo usage"
}

variable "use_alias_oracle_endpoint" {
  description = "use alias oracle instead of internal"
  type        = string
  default     = "no"
}

variable "internal_pm4ml_configs" {
  description = "pm4ml config data"
  type = list(object({
    DFSP_NAME         = string
    DFSP_CURRENCY     = string
    DFSP_PREFIX       = string
    DFSP_MSISDN       = string
    DFSP_ACCOUNT_ID   = string
    DFSP_NOTIFICATION_EMAIL = string
    PARTY_LAST_NAME = string
    PARTY_FIRST_NAME = string
    PARTY_MIDDLE_NAME = string
    PARTY_DOB = string
  }))
  default = []
}

variable "external_pm4ml_configs" {
  description = "pm4ml config data"
  type = list(object({
    DFSP_NAME         = string
    DFSP_CURRENCY     = string
    DFSP_PREFIX       = string
    DFSP_NOTIFICATION_EMAIL = string
    DFSP_SUBDOMAIN = string
  }))
  default = []
}

variable "mcm_name" {
  description = "Hostname of Connection Manager service"
  type        = string
  default     = "mcm"
}

variable "public_subdomain" {
  description = "public_subdomain"
  type        = string
}

variable "private_subdomain" {
  description = "private_subdomain"
  type        = string
}
variable "switch_jws_key" {
  description = "switch_jws_key"
  type        = string
  sensitive = true
}
variable "alias-oracle-fqdn" {
  description = "alias-oracle-fqdn"
  type        = string
}

variable "mfi-account-oracle-fqdn" {
  description = "mfi-account-oracle-fqdn"
  type        = string
}
variable "mfi-p2p-oracle-fqdn" {
  description = "mfi-p2p-oracle-fqdn"
  type        = string
}
variable "sim_whitelist_secret_name" {
  description = "sim_whitelist_secret_name"
  type        = string
}