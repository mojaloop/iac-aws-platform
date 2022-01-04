/* resource "aws_route53_record" "extgw-private" {
  zone_id = aws_route53_zone.main_private.zone_id
  name    = var.extgw_hostname
  type    = "CNAME"
  ttl     = "300"
  records = [module.nlb_int.private_dns]
}

resource "aws_route53_record" "intgw-private" {
  zone_id = aws_route53_zone.main_private.zone_id
  name    = var.intgw_hostname
  type    = "CNAME"
  ttl     = "300"
  records = [module.nlb_int.private_dns]
}

resource "aws_route53_record" "iskm-private" {
  zone_id = aws_route53_zone.main_private.zone_id
  name    = var.iskm_hostname
  type    = "CNAME"
  ttl     = "300"
  records = [module.nlb_int.private_dns]
}

resource "aws_route53_record" "grafana-services-private" {
  zone_id = aws_route53_zone.main_private.zone_id
  name    = var.grafana-services-name
  type    = "CNAME"
  ttl     = "300"
  records = [module.nlb_int.private_dns]
}
resource "aws_route53_record" "prometheus-services-private" {
  zone_id = aws_route53_zone.main_private.zone_id
  name    = var.prometheus-services-name
  type    = "CNAME"
  ttl     = "300"
  records = [module.nlb_int.private_dns]
} */