# IAM user with permissions to be able to update route53 records, for use with external-dns
resource "helm_release" "external-dns" {
  name       = "external-dns"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "external-dns"
  version    = var.helm_external_dns_version
  namespace  = var.external_dns_namespace
  timeout    = 300
  create_namespace = true
  provider = helm.helm-main
  values = [
    templatefile("${path.module}/templates/values-external-dns.yaml.tpl", {
        external_dns_iam_access_key = aws_iam_access_key.route53-external-dns.id
        external_dns_iam_secret_key = aws_iam_access_key.route53-external-dns.secret
        domain = var.public_subdomain
        internal_domain = var.private_subdomain
        txt_owner_id = "${var.environment}-${var.client}"
        region = var.region
      })
  ]
}

resource "kubernetes_secret" "certmanager-route53-credentials" {
  metadata {
    name = "certmanager-route53-credentials"
    namespace = var.cert_man_namespace
  }

  data = {
    secret-access-key = aws_iam_access_key.route53-external-dns.secret
  }

  type = "opaque"
  provider = kubernetes.k8s-main
  depends_on = [helm_release.cert-manager]
}

resource "aws_iam_user" "route53-external-dns" {
  name = "${var.environment}-${var.client}-external-dns"
  tags = merge({ Name = "${var.environment}-${var.client}-route53-external-dns" }, local.default_tags)
}
resource "aws_iam_access_key" "route53-external-dns" {
  user = aws_iam_user.route53-external-dns.name
}
# IAM Policy to allow external-dns user to update the given zone and cert-manager to create validation records
resource "aws_iam_user_policy" "route53-external-dns" {
  name = "${var.environment}-${var.client}-external-dns"
  user = aws_iam_user.route53-external-dns.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets"
      ],
      "Resource": [
        "arn:aws:route53:::hostedzone/${var.public_subdomain_zone_id}",    
        "arn:aws:route53:::hostedzone/${var.private_subdomain_zone_id}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [ 
        "route53:GetChange"
      ],
      "Resource": [ 
        "arn:aws:route53:::change/*" 
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ListHostedZones",
        "route53:ListResourceRecordSets",
        "route53:ListHostedZonesByName"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}
locals {
  dynamic_tags = {
    Environment = var.environment
    Tenant      = var.client
  }
  default_tags = merge(local.dynamic_tags, var.custom_tags)
}