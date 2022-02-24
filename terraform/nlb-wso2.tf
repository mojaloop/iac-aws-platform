/* module "nlb_ext" {
  for_each = {for i, val in data.aws_availability_zones.available.names: i => val}
  source = "git::https://github.com/mojaloop/iac-shared-modules//aws/nlb?ref=v2.0.1"
  vpc_id = data.aws_vpc.selected.id
  internal_lb = false
  enable_cross_zone_load_balancing = true
  prefix = "ext-${var.client}-${var.environment}-${each.value}"
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
  instance_ids = [for worker in module.k8-cluster-main.worker_nodes : worker.id if worker.availability_zone == each.value]
  subnet_id    = data.terraform_remote_state.tenant.outputs.public_subnet_ids["${var.environment}-${each.value}"]["id"]
}

module "nlb_int" {
  for_each = {for i, val in data.aws_availability_zones.available.names: i => val}
  source = "git::https://github.com/mojaloop/iac-shared-modules//aws/nlb?ref=v2.0.1"
  vpc_id = data.aws_vpc.selected.id
  internal_lb = true
  enable_cross_zone_load_balancing = true
  prefix = "int-${var.client}-${var.environment}-${each.value}"
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
  instance_ids = [for worker in module.k8-cluster-main.worker_nodes : worker.id if worker.availability_zone == each.value]
  subnet_id    = data.terraform_remote_state.tenant.outputs.public_subnet_ids["${var.environment}-${each.value}"]["id"]
} */