resource "aws_route53_record" "subdomain-ns" {
  allow_overwrite = true
  zone_id         = data.terraform_remote_state.tenant.outputs.public_zone_id
  name            = aws_route53_zone.public_subdomain.name
  type            = "NS"
  ttl             = "30"

  records = [
    aws_route53_zone.public_subdomain.name_servers.0,
    aws_route53_zone.public_subdomain.name_servers.1,
    aws_route53_zone.public_subdomain.name_servers.2,
    aws_route53_zone.public_subdomain.name_servers.3,
  ]
}

resource "null_resource" "wait_for_NS_propagation" {
  provisioner "local-exec" {
    command = "sleep 180"
  }
  depends_on = [aws_route53_record.subdomain-ns]
}

resource "aws_route53_record" "extgw-public" {
  zone_id = aws_route53_zone.public_subdomain.zone_id
  name    = var.extgw_hostname
  type    = "A"
  ttl     = 60

  records = [module.nlb_wso2.public_ip]
}

resource "aws_route53_record" "intgw-public" {
  zone_id = aws_route53_zone.public_subdomain.zone_id
  name    = var.intgw_hostname
  type    = "A"
  ttl     = 60

  records = [module.nlb_wso2.public_ip]
}

resource "aws_route53_record" "iskm-public" {
  zone_id = aws_route53_zone.public_subdomain.zone_id
  name    = var.iskm_hostname
  type    = "A"
  ttl     = 60

  records = [module.nlb_wso2.public_ip]
}

resource "aws_route53_record" "mcmweb-public" {
  zone_id = aws_route53_zone.public_subdomain.zone_id
  name    = var.mcm-name
  type    = "A"
  ttl     = 60

  records = [module.nlb_addons.public_ip]
}

resource "aws_route53_record" "pm4ml-public" {
  zone_id = aws_route53_zone.public_subdomain.zone_id
  name    = var.pm4ml-name
  type    = "A"
  ttl     = 60

  records = [module.nlb_addons.public_ip]
}
