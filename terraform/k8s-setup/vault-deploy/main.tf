resource "kubernetes_storage_class" "ebs" {
  metadata {
    name = "ebs"
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
  repository = "https://helm.releases.hashicorp.com"
  chart      = "consul"
  version    = var.helm_consul_version
  values     = [file("chart-values/consul.yml")]
  timeout    = 300

  provider   = helm.helm-gateway
  depends_on = [kubernetes_storage_class.ebs]
}

resource "helm_release" "deploy_vault" {
  name       = "vault"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"
  version    = var.helm_vault_version
  values     = [templatefile("chart-values/vault.yml.tpl", {
    aws_region = var.region,
    kms_key_id = aws_kms_key.vault_unseal_key.id,
    kms_access_key = var.aws_access_key,
    kms_secret_key = var.aws_secret_key,
    kube_engine_path = var.kubernetes_auth_path,
    vault_addr = "http://vault.${data.terraform_remote_state.infrastructure.outputs.private_subdomain}"
  })]
  force_update = true
  cleanup_on_fail = true
  timeout    = 300
  depends_on = [helm_release.deploy_consul, aws_kms_key.vault_unseal_key]
  provider   = helm.helm-gateway
}

data "kubernetes_service" "vault" {
  metadata {
    name = "vault-ui"
  }
  depends_on = [helm_release.deploy_vault]
  provider   = kubernetes.k8s-gateway
}

resource "aws_route53_record" "vault" {
  zone_id = data.terraform_remote_state.infrastructure.outputs.private_zone_id
  name    = "vault"
  type    = "CNAME"
  ttl     = "180"
  records = ["${data.kubernetes_service.vault.status.0.load_balancer.0.ingress.0.hostname}"]
}

resource "null_resource" "initialize-vault" {
  triggers = {
    always_run = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = <<EOT
export POD=$(kubectl get pod -l app.kubernetes.io/instance=vault -o jsonpath={.items[0].metadata.name})
if kubectl exec -ti $POD -c vault -- sh -c 'VAULT_ADDR=http://127.0.0.1:8200 vault status'; then
  echo "vault already initialized"
else 
kubectl exec -ti $POD -c vault -- sh -c 'VAULT_ADDR=http://127.0.0.1:8200 vault operator init --key-shares=5 --key-threshold=3 -format json' > ${var.project_root_path}/vault_seal_key
fi
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
POD=$(kubectl get pod -l app.kubernetes.io/instance=vault -o jsonpath={.items[0].metadata.name})
kubectl exec -ti $POD -c vault -- sh -c 'VAULT_ADDR=http://127.0.0.1:8200 VAULT_TOKEN=${jsondecode(file("${var.project_root_path}/vault_seal_key"))["root_token"]} vault secrets enable --path=secret kv' 
kubectl exec -ti $POD -c vault -- sh -c 'VAULT_ADDR=http://127.0.0.1:8200 VAULT_TOKEN=${jsondecode(file("${var.project_root_path}/vault_seal_key"))["root_token"]} vault secrets tune -default-lease-ttl=2m secret/' 
EOT
    environment = {
      KUBECONFIG = "${var.project_root_path}/admin-gateway.conf"
    }
  }
  depends_on = [null_resource.initialize-vault]
}
