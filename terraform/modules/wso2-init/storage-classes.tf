resource "kubernetes_storage_class" "wso2" {
  metadata {
    name = "slow"
  }
  storage_provisioner = "kubernetes.io/aws-ebs"
  reclaim_policy = "Retain"
  parameters  = {
      type = "gp2"
      iopsPerGB = "10"
      fsType = "ext4"
  }
}
