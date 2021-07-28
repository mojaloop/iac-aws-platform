module "k8-cluster-gateway" {
  name             = "gateway"
  source           = "./modules/k8-cluster"
  kube_master_num  = var.gateway_kube_master_num
  kube_master_size = var.gateway_kube_master_size
  kube_worker_num  = var.gateway_kube_worker_num
  kube_worker_size = var.gateway_kube_worker_size
  # TODO: get AZ from bootstrap tfstate
  availability_zone         = "${var.region}a"
  aws_ami                   = var.aws_ami
  kubemaster_iam_profile    = module.aws-iam.kube-master-profile
  kubeworker_iam_profile    = module.aws-iam.kube-worker-profile
  environment               = var.environment
  default_tags              = local.default_tags
  security_group_ids        = [aws_security_group.internet.id]
  ssh_key_name              = aws_key_pair.provisioner_key.key_name
  stage                     = var.environment
  subnet_id                 = data.terraform_remote_state.tenant.outputs.private_subnet_ids["${var.environment}-wso2"]["id"]
  kube_master_ebs_optimized = "false"
  kube_worker_ebs_optimized = "false"
  inventory_file            = var.inventory_file_gateway
  haproxy_size              = var.gw_haproxy_size
  haproxy_aliases           = var.k8-balancer-gateway-aliases
  route53_private_zone_id   = aws_route53_zone.main_private.zone_id
  route53_public_zone_id    = aws_route53_zone.main_private.zone_id
  route53_private_zone_name = aws_route53_zone.main_private.name
  route53_public_zone_name  = aws_route53_zone.main_private.name
}

module "k8-cluster-add-ons" {
  name             = "add-ons"
  source           = "./modules/k8-cluster"
  kube_master_num  = var.add-ons_kube_master_num
  kube_master_size = var.add-ons_kube_master_size
  kube_worker_num  = var.add-ons_kube_worker_num
  kube_worker_size = var.add-ons_kube_worker_size
  # TODO: get AZ from bootstrap tfstate
  availability_zone         = "${var.region}a"
  aws_ami                   = var.aws_ami
  kubemaster_iam_profile    = module.aws-iam.kube-master-profile
  kubeworker_iam_profile    = module.aws-iam.kube-worker-profile
  environment               = var.environment
  default_tags              = local.default_tags
  security_group_ids        = [aws_security_group.internet.id]
  ssh_key_name              = aws_key_pair.provisioner_key.key_name
  stage                     = var.environment
  subnet_id                 = data.terraform_remote_state.tenant.outputs.private_subnet_ids["${var.environment}-add-ons"]["id"]
  kube_master_ebs_optimized = "false"
  kube_worker_ebs_optimized = "false"
  inventory_file            = var.inventory_file_add-ons
  haproxy_size              = var.haproxy_size
  haproxy_aliases           = var.k8-balancer-add-ons-aliases
  route53_private_zone_id   = aws_route53_zone.main_private.zone_id
  route53_public_zone_id    = aws_route53_zone.main_private.zone_id
  route53_private_zone_name = aws_route53_zone.main_private.name
  route53_public_zone_name  = aws_route53_zone.main_private.name
}