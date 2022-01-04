variable "kubeconfig" {
  description = "Path to kubernetes config file"
  type = string
}

variable "region" {
  description = "AWS Region used"
  type = string
}

variable "environment" {
  description = "Environment Name"
  type = string
}

variable "mysql_version" {
  description = "Version of MySQL to deploy"
  type = string
}

variable "wso2_mysql_repo_version" {
  description = "https://github.com/mojaloop/wso2-mysql.git repo tag or branch name"
  type = string
}

variable "db_host" {
  description = "Hostname of the MySQL server"
  type = string
}

variable "db_name" {
  description = "MySQL Database name"
  type = string
}

variable "db_root_password" {
  description = "Password for DB 'root' user"
  type = string
}

variable "db_username" {
  description = "Username for DB"
  type = string
}

variable "db_password" {
  description = "Password for DB user"
  type = string
}

variable "helm_efs_provisioner_version" {
  description = "Chart version for the efs provisioner"
  type = string
}

variable "efs_subnet_id" {
  description = "Subnet ID to use with EFS"
  type = string
}

variable "efs_security_groups"  {
  description = "List of security group IDs to apply to the EFS. Must contain at least the sg id for the environment"
  type = list(string)
}

variable "efs_storage_class_name" {
  description = "storage class name for efs"
  type = string
  default = "efs"
}

variable "mysql_storage_class_name" {
  description = "storage class name for mysql"
  type = string
  default = "ebs"
}

variable "namespace" {
  description = "namespace to deploy to"
  type = string
  default = "wso2"
}