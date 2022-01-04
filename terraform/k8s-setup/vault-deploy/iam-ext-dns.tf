# IAM user with permissions to be able to update route53 records, for use with external-dns
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
        "arn:aws:route53:::hostedzone/${data.terraform_remote_state.infrastructure.outputs.public_subdomain_zone_id}",    
        "arn:aws:route53:::hostedzone/${data.terraform_remote_state.infrastructure.outputs.private_zone_id}"
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