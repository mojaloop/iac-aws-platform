resource "kubernetes_storage_class" "slow-add-ons" {
  metadata {
    name = "slow"
  }
  storage_provisioner = "kubernetes.io/aws-ebs"
  reclaim_policy      = "Retain"
  parameters = {
    type      = "gp2"
    iopsPerGB = "10"
    fsType    = "ext4"
  }
  provider = kubernetes.k8s-add-ons
}

resource "helm_release" "deploy-addons-nginx-ingress-controller" {
  name       = "nginx-ingress"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "nginx-ingress-controller"
  version    = var.helm_nginx_version
  namespace  = "default"
  wait       = false
  create_namespace = true

  set {
    name  = "service.nodePorts.http"
    value = 30001
  }
  provider = helm.helm-add-ons
}
