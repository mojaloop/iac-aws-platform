variable "kubeconfig" {
  description = "Path to kubernetes config file"
  type = string
}

variable "environment" {
  description = "Environment Name"
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

variable "db_root_password" {
  description = "Password for DB 'root' user"
  type = string
}
variable "namespace" {
  description = "namespace to deploy to"
  type = string
  default = "wso2"
}