module "nlb_addons" {
  source = "git@github.com:mojaloop/iac-shared-modules//aws/nlb?ref=v1.0.14"

  vpc_id = data.aws_vpc.selected.id
  prefix = "addons-${var.client}-${var.environment}"
  nlb_listeners = [
    {
      target_port          = 443
      protocol             = "TCP"
      deregistration_delay = 90
      interval             = 10
      health_port          = 443
      protocol             = "TCP"
      healthy_threshold    = 3
      unhealthy_threshold  = 3
    },
    {
      target_port          = 30000
      protocol             = "TCP"
      deregistration_delay = 90
      interval             = 10
      health_port          = 30000
      protocol             = "TCP"
      healthy_threshold    = 3
      unhealthy_threshold  = 3
    },
    {
      target_port          = 20000
      protocol             = "TCP"
      deregistration_delay = 90
      interval             = 10
      health_port          = 20000
      protocol             = "TCP"
      healthy_threshold    = 3
      unhealthy_threshold  = 3
    },
    {
      target_port          = 80
      protocol             = "TCP"
      deregistration_delay = 90
      interval             = 10
      health_port          = 80
      protocol             = "TCP"
      healthy_threshold    = 3
      unhealthy_threshold  = 3
    }

  ]
  instance_ids = [module.k8-cluster-add-ons.haproxy_id]
  subnet_id    = data.terraform_remote_state.tenant.outputs.public_subnet_ids["${var.environment}-gateway"]["id"]
}
