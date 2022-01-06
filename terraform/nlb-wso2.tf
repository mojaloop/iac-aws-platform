module "nlb_ext" {
  source = "git::https://github.com/mojaloop/iac-shared-modules//aws/nlb?ref=v2.0.0"
  vpc_id = data.aws_vpc.selected.id
  internal_lb = false
  prefix = "ext-${var.client}-${var.environment}"
  preserve_client_ip = true
  proxy_protocol = true
  nlb_listeners = [
    {
      target_port          = 32443
      listen_port          = 443
      protocol             = "TCP"
      deregistration_delay = 90
      interval             = 10
      health_port          = 32080
      protocol             = "TCP"
      healthy_threshold    = 3
      unhealthy_threshold  = 3
    },
    {
      target_port          = 32080
      listen_port          = 80
      protocol             = "TCP"
      deregistration_delay = 90
      interval             = 10
      health_port          = 32080
      protocol             = "TCP"
      healthy_threshold    = 3
      unhealthy_threshold  = 3
    }

  ]
  instance_ids = module.k8-cluster-gateway.worker_nodes_id
  subnet_id    = data.terraform_remote_state.tenant.outputs.public_subnet_ids["${var.environment}-gateway"]["id"]
}

module "nlb_int" {
  source = "git::https://github.com/mojaloop/iac-shared-modules//aws/nlb?ref=v2.0.0"
  vpc_id = data.aws_vpc.selected.id
  internal_lb = true
  prefix = "int-${var.client}-${var.environment}"
  preserve_client_ip = false  
  proxy_protocol = false 
  nlb_listeners = [
    {
      target_port          = 31443
      listen_port          = 443
      protocol             = "TCP"
      deregistration_delay = 90
      interval             = 10
      health_port          = 31080
      protocol             = "TCP"
      healthy_threshold    = 3
      unhealthy_threshold  = 3
    },
    {
      target_port          = 31080
      listen_port          = 80
      protocol             = "TCP"
      deregistration_delay = 90
      interval             = 10
      health_port          = 31080
      protocol             = "TCP"
      healthy_threshold    = 3
      unhealthy_threshold  = 3
    }

  ]
  instance_ids = module.k8-cluster-gateway.worker_nodes_id
  subnet_id    = data.terraform_remote_state.tenant.outputs.public_subnet_ids["${var.environment}-gateway"]["id"]
}
