terraform {
  required_version = ">= 1.0"
  backend "s3" {
    key     = "##environment##/terraform-vault.tfstate"
    encrypt = true
  }
  required_providers {
    helm = "1.2.4"
    kubernetes = "~> 1.13.3"
  }
}

resource "kubernetes_storage_class" "standard_encrypted" {
  metadata {
    name = "standard-encrypted"
  }
  storage_provisioner = "kubernetes.io/aws-ebs"
  reclaim_policy      = "Retain"
  parameters = {
    type      = "gp2"
    iopsPerGB = "10"
    fsType    = "ext4"
    encrypted = true
  }
  provider = kubernetes.k8s-gateway
}

resource "aws_kms_key" "vault_unseal_key" {
  description             = "KMS Key used to auto-unseal vault"
  deletion_window_in_days = 10
}

resource "helm_release" "deploy_consul" {
  name       = "consul"
  repository = "https://charts.helm.sh/stable"
  chart      = "consul"
  version    = var.helm_consul_version
  values     = [file("chart-values/consul.yml")]
  timeout    = 900

  provider   = helm.helm-gateway
  depends_on = [kubernetes_storage_class.standard_encrypted]
}

resource "helm_release" "deploy_vault" {
  name       = "vault"
  repository = "https://charts.helm.sh/incubator"
  chart      = "vault"
  version    = var.helm_vault_version
  values     = [file("chart-values/vault.yml")]
  timeout    = 900
  set {
    name  = "vault.config.seal.awskms.access_key"
    value = var.aws_access_key
    type  = "string"
  }
  set {
    name  = "vault.config.seal.awskms.secret_key"
    value = var.aws_secret_key
    type  = "string"
  }
  set {
    name  = "vault.config.seal.awskms.kms_key_id"
    value = aws_kms_key.vault_unseal_key.id
    type  = "string"
  }
  set {
    name  = "vault.config.seal.awskms.region"
    value = var.region
    type  = "string"
  }
  depends_on = [helm_release.deploy_consul, aws_kms_key.vault_unseal_key]
  provider   = helm.helm-gateway
}

data "kubernetes_service" "vault" {
  metadata {
    name = "vault"
  }
  depends_on = [helm_release.deploy_vault]
  provider   = kubernetes.k8s-gateway
}

resource "aws_route53_record" "vault" {
  zone_id = data.terraform_remote_state.infrastructure.outputs.private_zone_id
  name    = "vault"
  type    = "CNAME"
  ttl     = "180"
  records = ["${data.kubernetes_service.vault.load_balancer_ingress.0.hostname}"]
}

resource "null_resource" "initialize-vault" {
  triggers = {
    always_run = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = <<EOT
POD=$(kubectl get pod -l app=vault -o jsonpath={.items[0].metadata.name})
kubectl exec -ti $POD -c vault -- sh -c 'VAULT_ADDR=http://127.0.0.1:8200 vault operator init --key-shares=5 --key-threshold=3 -format json' > ${var.project_root_path}/vault_seal_key
EOT
    environment = {
      KUBECONFIG = "${var.project_root_path}/admin-gateway.conf"
    }
  }
  depends_on = [helm_release.deploy_vault]
}

data "template_file" "vault_key" {
  template = file("${var.project_root_path}/vault_seal_key")

  depends_on = [null_resource.initialize-vault]
}

resource "null_resource" "tune-secret-engine" {
  provisioner "local-exec" {
    command = <<EOT
POD=$(kubectl get pod -l app=vault -o jsonpath={.items[0].metadata.name})
kubectl exec -ti $POD -c vault -- sh -c 'VAULT_ADDR=http://127.0.0.1:8200 VAULT_TOKEN=${jsondecode(file("${var.project_root_path}/vault_seal_key"))["root_token"]} vault secrets tune -default-lease-ttl=2m secret/' 
EOT
    environment = {
      KUBECONFIG = "${var.project_root_path}/admin-gateway.conf"
    }
  }
  depends_on = [null_resource.initialize-vault]
}
