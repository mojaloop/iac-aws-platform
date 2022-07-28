locals {
  consul_num_replicas = length(data.terraform_remote_state.infrastructure.outputs.available_zones)
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
  values     = [templatefile("templates/values-consul.yaml.tpl", {
    storage_class_name = var.storage_class_name
    num_replicas = local.consul_num_replicas
  })]
  timeout    = 300
  provider   = helm.helm-gateway
  depends_on = [helm_release.longhorn]
}

resource "helm_release" "deploy_vault" {
  name       = "vault"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"
  version    = var.helm_vault_version
  values     = [templatefile("templates/values-vault.yaml.tpl", {
    aws_region = var.region,
    kms_key_id = aws_kms_key.vault_unseal_key.id,
    kms_access_key = var.aws_access_key,
    kms_secret_key = var.aws_secret_key,
    kube_engine_path = var.kubernetes_auth_path
    host_name = "vault"
    domain_name = data.terraform_remote_state.infrastructure.outputs.public_subdomain
  })]
  force_update = true
  cleanup_on_fail = true
  timeout    = 300
  depends_on = [helm_release.deploy_consul, aws_kms_key.vault_unseal_key, helm_release.internal-nginx-ingress-controller]
  provider   = helm.helm-gateway
}

data "kubernetes_service" "vault" {
  metadata {
    name = "vault-ui"
  }
  depends_on = [helm_release.deploy_vault]
  provider   = kubernetes.k8s-gateway
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

resource "helm_release" "cert-manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = var.helm_certmanager_version
  namespace  = var.cert_man_namespace
  timeout    = 300
  create_namespace = true
  set {
    name  = "installCRDs"
    value = "true"
  }
  provider = helm.helm-gateway
  depends_on = [helm_release.external-dns]
}

resource "helm_release" "external-dns" {
  name       = "external-dns"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "external-dns"
  version    = var.helm_external_dns_version
  namespace  = var.external_dns_namespace
  timeout    = 300
  create_namespace = true
  provider = helm.helm-gateway
  values = [
    templatefile("${path.module}/templates/values-external-dns.yaml.tpl", {
        external_dns_iam_access_key = aws_iam_access_key.route53-external-dns.id
        external_dns_iam_secret_key = aws_iam_access_key.route53-external-dns.secret
        domain = data.terraform_remote_state.infrastructure.outputs.public_subdomain
        internal_domain = data.terraform_remote_state.infrastructure.outputs.private_subdomain
        txt_owner_id = "${var.environment}-${var.client}"
        region = var.region
      })
  ]
}

resource "helm_release" "external-nginx-ingress-controller" {
  name       = "nginx-ext"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = var.helm_nginx_version
  namespace  = "nginx-ext"
  wait       = false
  create_namespace = true

  provider = helm.helm-gateway
  values = [
    templatefile("${path.module}/templates/values-nginx.yaml.tpl", {
        ingress_class_name = "nginx-ext"
        http_nodeport_port = 32080
        https_nodeport_port = 32443
        lb_name            = data.terraform_remote_state.infrastructure.outputs.external_load_balancer_dns
        use_proxy_protocol = true
        enable_real_ip     = true
        tls_sec_name = "default/${var.int_wildcard_cert_sec_name}"
      })
  ]
  depends_on = [time_sleep.wait_90_seconds-cert]
}

resource "helm_release" "internal-nginx-ingress-controller" {
  name       = "nginx-int"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = var.helm_nginx_version
  namespace  = "nginx-int"
  wait       = false
  create_namespace = true

  provider = helm.helm-gateway
  values = [
    templatefile("${path.module}/templates/values-nginx.yaml.tpl", {
        http_nodeport_port = 31080
        https_nodeport_port = 31443
        ingress_class_name = "nginx"
        lb_name            = data.terraform_remote_state.infrastructure.outputs.internal_load_balancer_dns
        use_proxy_protocol = false
        enable_real_ip     = false
        tls_sec_name = "default/${var.int_wildcard_cert_sec_name}"
      })
  ]
  depends_on = [time_sleep.wait_90_seconds-cert]
}
