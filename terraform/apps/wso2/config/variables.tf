variable "region" {
  description = "AWS region"
  type        = string
}

variable "tenant" {
  description = "Tenant name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_root_path" {
  description = "Root path for IaC project"
}
