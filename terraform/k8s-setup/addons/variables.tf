variable "environment" {
  description = "Environment name"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "tenant" {
  description = "Tenant name"
  type        = string
}

variable "project_root_path" {
  description = "Root path for IaC project"
}

variable "simulator_names" {
  description = "Simulator Names. This will be used to create dns records and deploy sims to k8s"
  type        = list(string)
  default     = ["payerfsp", "payeefsp", "testfsp1", "testfsp2", "testfsp3", "testfsp4", "pm4mlreceiverfsp", "pm4mlsenderfsp"]
}

variable "simulator_cidr_blocks" {
  description = "Simulator CIDR Blocks for whitelisting the matching simulator_names list variable"
  type        = list(string)
  default     = ["10.0.0.0/8", "10.0.0.0/8", "10.0.0.0/8", "10.0.0.0/8", "10.0.0.0/8", "10.0.0.0/8", "10.0.0.0/8", "10.0.0.0/8"]
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

variable "helm_mysql_mcm_version" {
  description = "version of the mcm helm chart to install"
  type        = string
}

variable "helm_mcm_connection_manager_version" {
  description = "version of the mcm helm chart to install"
  type        = string
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

variable "mcm-mysql-password" {
  description = "Password for Connection Manager MySQL server"
  type        = string
  default     = "devdat1asql1"
}

variable "mcm-mysql-root-password" {
  description = "Root password for Connection Manager MySQL server"
  type        = string
  default     = "Hola87654321!"
}

variable "hub_currency_code" {
  description = "currency code for the hub"
  type        = string
}

variable "iac_post_init_version" {
  description = "tag on iac post init repo"
  type        = string
}

variable "sdks" {
  description = "List of SDKs to create for the environment"
  type = list(object({
    name               = string,
    currency           = string,
    msisdn             = number,
    business_id        = string,
    notification_email = string,
    account_id         = string,
    sim_endpoint       = string
  }))
  default = []
}

variable "helm_mojaloop_version" {
  description = "Mojaloop version to install via Helm"
}
