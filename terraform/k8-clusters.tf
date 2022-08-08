module "k8-cluster-main" {
  name             = "main"
  source           = "./modules/k8-cluster"
  environment               = var.environment
  default_tags              = local.default_tags
  tenant                    = var.client
  inventory_file            = var.inventory_file_gateway
  route53_private_zone_id   = aws_route53_zone.main_private.zone_id
  route53_public_zone_id    = aws_route53_zone.main_private.zone_id
  route53_private_zone_name = aws_route53_zone.main_private.name
  route53_public_zone_name  = aws_route53_zone.main_private.name
  worker_kube_ec2_config = local.worker_kube_ec2_config
  master_kube_ec2_config = local.master_kube_ec2_config
}

module "ubuntu-bionic-ami" {
  source  = "git::https://github.com/mojaloop/iac-shared-modules.git//aws/ami-ubuntu?ref=v1.0.41"
  release = "18.04"
}

module "ubuntu-focal-ami" {
  source  = "git::https://github.com/mojaloop/iac-shared-modules.git//aws/ami-ubuntu?ref=v1.0.41"
  release = "20.04"
}

locals {
  master_node_permutations = {for pair in setproduct(local.availability_zones, range(var.kube_master_num)) : "${pair[0]}-${pair[1]}" => pair[0]}
  worker_node_permutations = {for pair in setproduct(local.availability_zones, range(var.kube_worker_num)) : "${pair[0]}-${pair[1]}" => pair[0]}
  
  master_kube_ec2_config = [
    for cluster_ref, az in local.master_node_permutations : 
    {
      "subnet_id" = data.terraform_remote_state.tenant.outputs.private_subnet_ids["${var.environment}-${az}"]["id"]
      "availability_zone" = az
      "ec2_ref" = cluster_ref
      "aws_ami" = var.use_focal_ubuntu ? module.ubuntu-focal-ami.id : module.ubuntu-bionic-ami.id
      "ec2_size" = var.kube_master_size
      "ebs_optimized" = false
      "security_group_ids" = [aws_security_group.internet.id]
      "ssh_key_name"       = aws_key_pair.provisioner_key.key_name
      "iam_profile" = module.aws-iam.kube-master-profile
      "root_volume_size" = var.kube_master_rootfs_size
    }
  ]
  worker_kube_ec2_config = [
    for cluster_ref, az in local.worker_node_permutations : 
    {
      "subnet_id" = data.terraform_remote_state.tenant.outputs.private_subnet_ids["${var.environment}-${az}"]["id"]
      "availability_zone" = az
      "ec2_ref" = cluster_ref
      "aws_ami" = var.use_focal_ubuntu ? module.ubuntu-focal-ami.id : module.ubuntu-bionic-ami.id
      "ec2_size" = var.kube_worker_size
      "ebs_optimized" = false
      "security_group_ids" = [aws_security_group.internet.id]
      "ssh_key_name"       = aws_key_pair.provisioner_key.key_name
      "iam_profile" = module.aws-iam.kube-worker-profile
      "root_volume_size" = var.kube_worker_rootfs_size
    }
  ]
}