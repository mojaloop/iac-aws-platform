resource "aws_route53_record" "simulators-public" {
  for_each = toset(var.simulator_names)
  zone_id  = data.terraform_remote_state.infrastructure.outputs.public_subdomain_zone_id
  name     = each.value
  type     = "A"
  ttl      = 60

  records = [data.terraform_remote_state.infrastructure.outputs.addons_eip_public_ip]
}