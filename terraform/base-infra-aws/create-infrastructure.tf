resource "null_resource" "oauth-app" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "curl -v -X POST https://${local.gitlab_hostname}/api/v4/applications -H 'Content-Type: application/json' -H 'PRIVATE-TOKEN: ${local.gitlab_root_token}' -d '{\"name\": \"oauth-app-kubernetes-${var.environment}\", \"redirect_uri\": \"https://grafana.${aws_route53_zone.public_subdomain.name}/login/gitlab\", \"scopes\": \"read_api openid\" }' > ${path.module}/oauth-apps/oauth-app-kubernetes-${var.environment}.json"
  }
}

data "local_file" "kubernetes-oauth-app" {
  filename   = "${path.module}/oauth-apps/oauth-app-kubernetes-${var.environment}.json"
  depends_on = [null_resource.oauth-app]
}

resource "null_resource" "grafana-oauth-app" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "curl -v -X POST https://${local.gitlab_hostname}/api/v4/applications -H 'Content-Type: application/json' -H 'PRIVATE-TOKEN: ${local.gitlab_root_token}' -d '{\"name\": \"oauth-app-grafana-${var.environment}\", \"redirect_uri\": \"https://grafana.${aws_route53_zone.public_subdomain.name}/login/gitlab\", \"scopes\": \"read_api\" }' > ${path.module}/oauth-apps/oauth-app-grafana-${var.environment}.json"
  }
}

data "local_file" "grafana-oauth-app" {
  filename   = "${path.module}/oauth-apps/oauth-app-grafana-${var.environment}.json"
  depends_on = [null_resource.grafana-oauth-app]
}

resource "null_resource" "vault-oauth-app" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "curl -v -X POST https://${local.gitlab_hostname}/api/v4/applications -H 'Content-Type: application/json' -H 'PRIVATE-TOKEN: ${local.gitlab_root_token}' -d '{\"name\": \"oauth-app-vault-${var.environment}\", \"redirect_uri\": \"https://vault.${aws_route53_zone.public_subdomain.name}/ui/vault/auth/oidc/oidc/callback\", \"scopes\": \"openid\" }' > ${path.module}/oauth-apps/oauth-app-vault-${var.environment}.json"
  }
}

data "local_file" "vault-oauth-app" {
  filename   = "${path.module}/oauth-apps/oauth-app-vault-${var.environment}.json"
  depends_on = [null_resource.vault-oauth-app]
}

#creating nexus entries json file for kubespray execution (requires bootstrap version >= v0.5.3)
resource "local_file" "kubespray_extra_vars" {
  content = templatefile("${path.module}/templates/extra-vars.json.tpl", {
    nexus_ip                           = local.nexus_fqdn
    nexus_port                         = local.nexus_docker_repo_listening_port
    apiserver_loadbalancer_domain_name = aws_lb.internal-lb.dns_name
    kube_oidc_enabled                  = "true"
    kube_oidc_client_id                = local.oauth_app_id
    kube_oidc_url                      = "https://${local.gitlab_hostname}"
    groups_name                        = "groups_direct"
  })
  filename = "${path.module}/extra-vars.json"
}

data "aws_vpc" "selected" {
  id = local.vpc_id
}

resource "aws_security_group" "internet" {
  name   = "${var.environment}-${var.client}-internet"
  tags   = local.default_tags
  vpc_id = data.aws_vpc.selected.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  lifecycle {
    create_before_destroy = true
  }
}
# TODO: was is this even for?
module "aws-iam" {
  source = "git::https://github.com/mojaloop/iac-shared-modules//aws/iam?ref=v1.0.21"

  aws_cluster_name = "${var.environment}-${var.client}"
}

resource "aws_route53_zone" "main_private" {
  name = "${var.environment}.${local.private_subdomain}"
  force_destroy = var.route53_zone_force_destroy
  vpc {
    vpc_id = data.aws_vpc.selected.id
  }

  comment = "Private zone for ${local.private_subdomain}"

  tags = {
    "ProductDomain" = local.private_subdomain
    "Environment"   = var.environment
    "Description"   = "Private zone for ${local.private_subdomain}"
    "ManagedBy"     = "Terraform"
  }
}

resource "aws_route53_zone" "public_subdomain" {
  name          = "${var.environment}.${local.public_subdomain}"
  force_destroy = var.route53_zone_force_destroy
  tags = {
    "ProductDomain" = local.public_subdomain
    "Environment"   = var.environment
    "Description"   = "Public Zone for subdomain ${local.public_subdomain}"
    "ManagedBy"     = "Terraform"
  }
}

resource "aws_route53_record" "subdomain-ns" {
  allow_overwrite = true
  zone_id         = local.public_zone_id
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

locals {
  dynamic_tags = {
    Environment = var.environment
    Tenant      = var.client
  }
  default_tags = merge(local.dynamic_tags, var.custom_tags)
  oauth_app_id = jsondecode(data.local_file.kubernetes-oauth-app.content)["application_id"]
}
