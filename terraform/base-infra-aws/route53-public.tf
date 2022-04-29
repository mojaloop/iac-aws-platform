/* resource "aws_route53_record" "extgw-public" {
  zone_id = aws_route53_zone.public_subdomain.zone_id
  name    = var.extgw_hostname
  type    = "A"
  ttl     = 60

  records = [module.nlb_ext.public_ip]
}

resource "aws_route53_record" "intgw-public" {
  zone_id = aws_route53_zone.public_subdomain.zone_id
  name    = var.intgw_hostname
  type    = "A"
  ttl     = 60

  records = [module.nlb_ext.public_ip]
}

resource "aws_route53_record" "iskm-public" {
  zone_id = aws_route53_zone.public_subdomain.zone_id
  name    = var.iskm_hostname
  type    = "A"
  ttl     = 60

  records = [module.nlb_ext.public_ip]
}

resource "aws_route53_record" "mcmweb-public" {
  zone_id = aws_route53_zone.public_subdomain.zone_id
  name    = var.mcm-name
  type    = "A"
  ttl     = 60

  records = [module.nlb_ext.public_ip]
} */

