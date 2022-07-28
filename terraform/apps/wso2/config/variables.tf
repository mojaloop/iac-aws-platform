variable "region" {
  description = "AWS region"
  type        = string
}

variable "client" {
  description = "Name of client"
  type        = string
}

variable "bucket" {
  description = "Name of aws s3 bucket"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_root_path" {
  description = "Root path for IaC project"
}
