resource "aws_efs_file_system" "wso2" {
  provisioned_throughput_in_mibps = "4"
  throughput_mode                 = "provisioned"
}

resource "aws_efs_mount_target" "wso2" {
  file_system_id  = join("", aws_efs_file_system.wso2.*.id)
  subnet_id       = var.efs_subnet_id
  security_groups = var.efs_security_groups
}

resource "null_resource" "wait_for_efs_NS_propagation" {
  provisioner "local-exec" {
    command = "sleep 90"
  }
  depends_on = [aws_efs_mount_target.wso2]
}

resource "helm_release" "efs-setup" {
  name       = "efs-provisioner"
  repository = "https://charts.helm.sh/stable"
  chart      = "efs-provisioner"
  version    = var.helm_efs_provisioner_version
  namespace  = var.namespace
  timeout    = "600"
  create_namespace = true

  set {
    name  = "efsProvisioner.efsFileSystemId"
    value = join("", aws_efs_file_system.wso2.*.id)
    type  = "string"
  }
  set {
    name  = "efsProvisioner.dnsName"
    value = aws_efs_mount_target.wso2.mount_target_dns_name
    type  = "string"
  }
  set {
    name  = "efsProvisioner.awsRegion"
    value = var.region
    type  = "string"
  }
  set {
    name  = "efsProvisioner.storageClass.reclaimPolicy"
    value = "Retain"
    type  = "string"
  }
  set {
    name  = "efsProvisioner.storageClass.name"
    value = var.efs_storage_class_name
    type  = "string"
  }
  depends_on = [null_resource.wait_for_efs_NS_propagation]
}
