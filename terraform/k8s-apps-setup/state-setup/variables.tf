variable "region" {
  description = "AWS region"
}
variable "environment" {
  description = "Environment name"
  type        = string
}
variable "client" {
  description = "Name of client"
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
