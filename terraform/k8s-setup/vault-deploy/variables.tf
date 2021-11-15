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
variable "kubernetes_auth_path" {
  description = "vault kube auth engine path"
  type        = string
  default     = "kubernetes-gateway"
}
variable "environment" {
  description = "Environment name"
  type        = string
}
variable "client" {
  description = "Name of client"
  type        = string
}