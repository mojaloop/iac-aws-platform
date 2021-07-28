variable "helm_consul_version" {
  description = "chart version to deploy consul"
}
variable "helm_vault_version" {
  description = "chart version to deploy vault"
}
variable "aws_access_key" {
  description = "AWS Access Key to manage KMS access"
}
variable "region" {
  description = "AWS region"
}
variable "aws_secret_key" {
  description = "AWS Secret Key to manage KMS access"
}
variable "project_root_path" {
  description = "Root folder for the infrastructure code"
}
