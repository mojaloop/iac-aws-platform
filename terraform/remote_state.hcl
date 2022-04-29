remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    bucket         = "${get_env("client")}-mojaloop-state"
    key            = "${get_env("environment")}/${path_relative_to_include()}/terraform.tfstate"
    region         = "${get_env("region")}"
    encrypt        = true
    dynamodb_table = "${get_env("client")}-mojaloop-lock"
  }
}