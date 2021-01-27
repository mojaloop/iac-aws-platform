module "nlb_wso2" {
  source = "git@github.com:mojaloop/iac-shared-modules.git//aws/nlb?ref=v0.0.2"

  vpc_id = data.aws_vpc.selected.id
  prefix = "wso2-${var.tenant}-${var.environment}"
  nlb_listeners = [
    {
      target_port          = 9443
      protocol             = "TCP"
      deregistration_delay = 90
      interval             = 10
      health_port          = 9443
      protocol             = "TCP"
      healthy_threshold    = 3
      unhealthy_threshold  = 3
    },
    {
      target_port          = 9543
      protocol             = "TCP"
      deregistration_delay = 90
      interval             = 10
      health_port          = 9543
      protocol             = "TCP"
      healthy_threshold    = 3
      unhealthy_threshold  = 3
    },
    {
      target_port          = 8243
      protocol             = "TCP"
      deregistration_delay = 90
      interval             = 10
      health_port          = 8243
      protocol             = "TCP"
      healthy_threshold    = 3
      unhealthy_threshold  = 3
    }

  ]
  instance_ids = [module.k8-cluster-gateway.haproxy_id]
  subnet_id    = data.terraform_remote_state.tenant.outputs.public_subnet_ids["${var.environment}-gateway"]["id"]
}
