resource "aws_efs_file_system" "wso2" {
  provisioned_throughput_in_mibps = "4"
  throughput_mode                 = "provisioned"
}

resource "aws_efs_mount_target" "wso2" {
  file_system_id  = join("", aws_efs_file_system.wso2.*.id)
  subnet_id       = var.efs_subnet_id
  security_groups = var.efs_security_groups
}

resource "helm_release" "efs-setup" {
  name       = "efs-provisioner"
  repository = "https://charts.helm.sh/stable"
  chart      = "efs-provisioner"
  version    = var.helm_efs_provisioner_version
  namespace  = "mysql-wso2"
  timeout    = "600"

  set {
    name  = "efsProvisioner.efsFileSystemId"
    value = join("", aws_efs_file_system.wso2.*.id)
  }

  set {
    name  = "efsProvisioner.awsRegion"
    value = var.region
  }
  set {
    name  = "efsProvisioner.storageClass.reclaimPolicy"
    value = "Retain"
  }
}
