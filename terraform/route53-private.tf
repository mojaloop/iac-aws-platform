resource "aws_route53_record" "extgw-private" {
  zone_id = aws_route53_zone.main_private.zone_id
  name    = var.extgw_hostname
  type    = "A"
  ttl     = "300"
  records = [module.k8-cluster-gateway.haproxy_private_ip]
}

resource "aws_route53_record" "intgw-private" {
  zone_id = aws_route53_zone.main_private.zone_id
  name    = var.intgw_hostname
  type    = "A"
  ttl     = "300"
  records = [module.k8-cluster-gateway.haproxy_private_ip]
}

resource "aws_route53_record" "iskm-private" {
  zone_id = aws_route53_zone.main_private.zone_id
  name    = var.iskm_hostname
  type    = "A"
  ttl     = "300"
  records = [module.k8-cluster-gateway.haproxy_private_ip]
}

resource "aws_route53_record" "mcmweb-private" {
  zone_id = aws_route53_zone.main_private.zone_id
  name    = var.mcm-name
  type    = "A"
  ttl     = "300"
  records = [module.k8-cluster-add-ons.haproxy_private_ip]
}

resource "aws_route53_record" "elasticsearch-services-private" {
  zone_id = aws_route53_zone.main_private.zone_id
  name    = var.elasticsearch-services-name
  type    = "A"
  ttl     = "300"
  records = [module.k8-cluster-support-services.haproxy_private_ip]
}

resource "aws_route53_record" "apm-services-private" {
  zone_id = aws_route53_zone.main_private.zone_id
  name    = var.apm-services-name
  type    = "A"
  ttl     = "300"
  records = [module.k8-cluster-support-services.haproxy_private_ip]
}

resource "aws_route53_record" "kibana-services-private" {
  zone_id = aws_route53_zone.main_private.zone_id
  name    = var.kibana-services-name
  type    = "A"
  ttl     = "300"
  records = [module.k8-cluster-support-services.haproxy_private_ip]
}
resource "aws_route53_record" "grafana-services-private" {
  zone_id = aws_route53_zone.main_private.zone_id
  name    = var.grafana-services-name
  type    = "A"
  ttl     = "300"
  records = [module.k8-cluster-support-services.haproxy_private_ip]
}
resource "aws_route53_record" "prometheus-services-private" {
  zone_id = aws_route53_zone.main_private.zone_id
  name    = var.prometheus-services-name
  type    = "A"
  ttl     = "300"
  records = [module.k8-cluster-support-services.haproxy_private_ip]
}
resource "aws_route53_record" "prometheus-add-ons-private" {
  zone_id = aws_route53_zone.main_private.zone_id
  name    = var.prometheus-add-ons-name
  type    = "A"
  ttl     = "300"
  records = [module.k8-cluster-add-ons.haproxy_private_ip]
}
resource "aws_route53_record" "prometheus-mojaloop-private" {
  zone_id = aws_route53_zone.main_private.zone_id
  name    = var.prometheus-mojaloop-name
  type    = "A"
  ttl     = "300"
  records = [module.k8-cluster-mojaloop.haproxy_private_ip]
}
resource "aws_route53_record" "prometheus-gateway-private" {
  zone_id = aws_route53_zone.main_private.zone_id
  name    = var.prometheus-gateway-name
  type    = "A"
  ttl     = "300"
  records = [module.k8-cluster-gateway.haproxy_private_ip]
}