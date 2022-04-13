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

variable "project_root_path" {
  description = "Root path for IaC project"
}

variable "simulator_names" {
  description = "Simulator Names. This will be used to create dns records and deploy sims to k8s"
  type        = list(string)
  default     = ["payerfsp", "payeefsp", "testfsp1", "testfsp2", "testfsp3", "testfsp4"]
}

variable "simulator_cidr_block" {
  description = "Simulator CIDR Block for whitelisting sims"
  type        = string
  default     = "10.25.0.0/16"
}

variable "hub_account_names" {
  description = "other non sim account names. this will create accounts and whitelist entries"
  type        = list(string)
  default     = ["noresponsepayeefsp"]
}

variable "hub_account_cidr_blocks" {
  description = "Simulator CIDR Blocks for whitelisting the matching simulator_names list variable"
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

variable "helm_mojaloop_simulator_version" {
  description = "Mojaloop Simulator version to install via Helm"
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

variable "pm4ml_nat_ips" {
  description = "pm4ml nat gateway ips"
  type = list(string)
  default = ["192.168.0.1", "192.168.0.2", "192.168.0.3"]
}

variable "helm_finance_portal_version" {
  default = ""
}

variable "helm_bof_version" {
  default = ""
}

variable "helm_mcm_connection_manager_version" {
  default = ""
}