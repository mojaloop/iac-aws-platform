generate "provider" {
  path = "k8s_providers.tf"
 
  if_exists = "overwrite_terragrunt"
 
  contents = < < EOF
provider "helm" {
  alias = "helm-main"
  kubernetes {
    config_path = get_env("kubeconfig_location")
  }
}
provider "kubernetes" {
  alias       = "k8s-main"
  config_path = get_env("kubeconfig_location")
}

provider "kubectl" {
  alias       = "k8s-main"
  config_path = get_env("kubeconfig_location")
}
 
EOF
}