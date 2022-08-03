variable "region" {
  description = "AWS region"
}
variable "project_root_path" {
  description = "Root folder for the infrastructure code"
}
variable "environment" {
  description = "Environment name"
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

variable "storage_class_name" {
  description = "storage class name"
  type        = string
  default     = "longhorn"
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
      })
      mongodb_data = object({
        root_password = string
        user = string
        user_password = string
        database_name = string
        storage_size = string
      })
      kafka_data = object({
        storage_size = string
      })
    }) 
  }))
  default = []
}