resource "aws_key_pair" "provisioner_key" {
  key_name   = "${var.name}-${var.environment}-deployer-key"
  public_key = tls_private_key.provisioner_key.public_key_openssh

  tags = var.default_tags
}

resource "tls_private_key" "provisioner_key" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "local_file" "provisioner_key" {
  content         = tls_private_key.provisioner_key.private_key_pem
  filename        = "${path.module}/ssh_provisioner_key"
  file_permission = "0600"
}
