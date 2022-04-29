generate "provider" {
  path = "aws_provider.tf"
 
  if_exists = "overwrite_terragrunt"
 
  contents = <<EOF
provider "aws" {
  region = "${get_env("region")}"
}
 
EOF
}