provider "acme" {
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}

resource "tls_private_key" "acme_private_key" {
  algorithm = "RSA"
}

resource "acme_registration" "iskm_acme_reg" {
  account_key_pem = tls_private_key.acme_private_key.private_key_pem
  email_address   = var.wso2_email
}

resource "acme_certificate" "iskm_acme_certificate" {
  account_key_pem           = acme_registration.iskm_acme_reg.account_key_pem
  common_name               = aws_route53_record.iskm-public-private.fqdn

  dns_challenge {
    provider = "route53"
  }
}

resource "aws_route53_record" "iskm-public-private" {
  zone_id = data.terraform_remote_state.infrastructure.outputs.public_subdomain_zone_id
  name    = "iskmssl"
  type    = "A"
  ttl     = "300"
  records = [data.terraform_remote_state.infrastructure.outputs.haproxy_gateway_private_ip]
}
