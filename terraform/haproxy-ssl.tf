resource "aws_instance" "haproxy-callback" {
  ami           = var.aws_ami
  instance_type = var.haproxy_size

  # TODO: get AZ from bootstrap tfstate
  availability_zone = "${var.region}a"

  subnet_id = data.terraform_remote_state.tenant.outputs.private_subnet_ids["${var.environment}-wso2"]["id"]

  vpc_security_group_ids = [aws_security_group.internet.id]

  iam_instance_profile = module.aws-iam.kube-master-profile
  key_name             = aws_key_pair.provisioner_key.key_name

  tags = merge(
    var.default_tags,
    {
      Name = "haproxy-callback-${var.environment}"

    },
  )
}

resource "aws_route53_record" "haproxy-callback" {
  zone_id = aws_route53_zone.main_private.zone_id
  name    = "haproxy-callback"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.haproxy-callback.private_ip]
}
