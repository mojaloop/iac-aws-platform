// Backend Dependencies

//// Databases
resource "helm_release" "keto-db" {
  name       = "keto-db"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "mysql"
  version    = "8.8.8"
  namespace  = "mojaloop"
  timeout    = 300

  values = [
    templatefile("${path.module}/templates/values-keto-db.yaml.tpl", {
    })
  ]
  provider = helm.helm-gateway
  depends_on = [helm_release.mojaloop]
}

resource "helm_release" "kratos-db" {
  name       = "kratos-db"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "mysql"
  version    = "8.8.8"
  namespace  = "mojaloop"
  timeout    = 300

  values = [
    templatefile("${path.module}/templates/values-kratos-db.yaml.tpl", {
    })
  ]
  provider = helm.helm-gateway
  depends_on = [helm_release.mojaloop]
}

resource "helm_release" "reporting-events-db" {
  name       = "reporting-events-db"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "mongodb"
  version    = "10.28.1"
  namespace  = "mojaloop"
  timeout    = 300

  values = [
    templatefile("${path.module}/templates/values-reporting-events-db.yaml.tpl", {
    })
  ]
  provider = helm.helm-gateway
  depends_on = [helm_release.mojaloop]
}

//// Ory Services
resource "helm_release" "keto" {
  name       = "keto"
  repository = "https://k8s.ory.sh/helm/charts"
  chart      = "keto"
  version    = var.helm_keto_version
  namespace  = "mojaloop"
  timeout    = 300

  values = [
    templatefile("${path.module}/templates/values-keto.yaml.tpl", {
    })
  ]
  provider = helm.helm-gateway
  depends_on = [helm_release.mojaloop]
}

resource "helm_release" "oathkeeper" {
  name       = "oathkeeper"
  repository = "https://k8s.ory.sh/helm/charts"
  chart      = "oathkeeper"
  version    = var.helm_oathkeeper_version
  namespace  = "mojaloop"
  timeout    = 300

  values = [  
    templatefile(split(".", var.k8s_api_version)[1] > 18 ? "${path.module}/templates/values-oathkeeper.yaml.tpl" : "${path.module}/templates/values-oathkeeper_pre_1_19.yaml.tpl", {
      wso2_host = "https://${aws_route53_record.iskm-public-private.fqdn}:7443"
      wso2_admin_creds = base64encode("admin:${vault_generic_secret.wso2_admin_password.data.value}")
      portal_fqdn = aws_route53_record.bofportal-gateway-private.fqdn
    })
  ]
  provider = helm.helm-gateway
  depends_on = [helm_release.bof-rules]
}

resource "helm_release" "oathkeeper-maester" {
  name       = "oathkeeper-maester"
  repository = "https://k8s.ory.sh/helm/charts"
  chart      = "oathkeeper-maester"
  version    = var.helm_oathkeeper_version
  namespace  = "mojaloop"
  timeout    = 300
  skip_crds  = false

  values = [
    templatefile("${path.module}/templates/values-oathkeeper-maester.yaml.tpl", {
    })
  ]
  provider = helm.helm-gateway
  depends_on = [helm_release.mojaloop]
}

resource "helm_release" "kratos" {
  name       = "kratos"
  repository = "https://k8s.ory.sh/helm/charts"
  chart      = "kratos"
  version    = var.helm_kratos_version
  namespace  = "mojaloop"
  timeout    = 300

  values = [
    templatefile("${path.module}/templates/values-kratos.yaml.tpl", {
      wso2_host = "https://${aws_route53_record.iskm-public-private.fqdn}:7443"
      portal_fqdn = aws_route53_record.bofportal-gateway-private.fqdn
      wso2_client_id = module.bizops-portal-iskm.consumer-key
      wso2_client_secret = module.bizops-portal-iskm.consumer-secret
    })
  ]
  provider = helm.helm-gateway
  depends_on = [helm_release.mojaloop]
}

// BOF consolidated chart

resource "helm_release" "bof" {
  name       = "bof"
  repository = "http://docs.mojaloop.io/charts/repo"
  chart      = "bof"
  version    = var.helm_bof_version
  devel      = true
  namespace  = "mojaloop"
  timeout    = 300
  force_update = true

  values = [
    templatefile("${path.module}/templates/values-bof.yaml.tpl", {
      wso2_host = "https://${aws_route53_record.iskm-public-private.fqdn}:7443"
      portal_fqdn = aws_route53_record.bofportal-gateway-private.fqdn
      api_fqdn = aws_route53_record.bofapi-gateway-private.fqdn
      iamui_fqdn = aws_route53_record.bofiamui-gateway-private.fqdn
      transfersui_fqdn = aws_route53_record.boftransfersui-gateway-private.fqdn
      settlementsui_fqdn = aws_route53_record.bofsettlementsui-gateway-private.fqdn
      positionsui_fqdn = aws_route53_record.bofpositionsui-gateway-private.fqdn
      central_admin_host = "moja-centralledger-service"
      central_settlements_host = "moja-centralsettlement-service"
      kafka_host = "moja-kafka-headless"
      reporting_db_host = "moja-centralledger-mysql"
      reporting_db_port = "3306"
      reporting_db_user = "central_ledger"
      reporting_db_database = "central_ledger"
      reporting_db_secret_name = "moja-centralledger-mysql"
      reporting_db_secret_key = "mysql-password"
    })
  ]
  provider = helm.helm-gateway
  depends_on = [helm_release.mojaloop]
}
resource "aws_route53_record" "bofportal-gateway-private" {
  zone_id = data.terraform_remote_state.infrastructure.outputs.private_zone_id
  name    = var.bofportal_name
  type    = "A"
  ttl     = "300"
  records = [data.terraform_remote_state.infrastructure.outputs.haproxy_gateway_private_ip]
}
resource "aws_route53_record" "bofiamui-gateway-private" {
  zone_id = data.terraform_remote_state.infrastructure.outputs.private_zone_id
  name    = var.bofiamui_name
  type    = "A"
  ttl     = "300"
  records = [data.terraform_remote_state.infrastructure.outputs.haproxy_gateway_private_ip]
}
resource "aws_route53_record" "boftransfersui-gateway-private" {
  zone_id = data.terraform_remote_state.infrastructure.outputs.private_zone_id
  name    = var.boftransfersui_name
  type    = "A"
  ttl     = "300"
  records = [data.terraform_remote_state.infrastructure.outputs.haproxy_gateway_private_ip]
}
resource "aws_route53_record" "bofsettlementsui-gateway-private" {
  zone_id = data.terraform_remote_state.infrastructure.outputs.private_zone_id
  name    = var.bofsettlementsui_name
  type    = "A"
  ttl     = "300"
  records = [data.terraform_remote_state.infrastructure.outputs.haproxy_gateway_private_ip]
}
resource "aws_route53_record" "bofpositionsui-gateway-private" {
  zone_id = data.terraform_remote_state.infrastructure.outputs.private_zone_id
  name    = var.bofpositionsui_name
  type    = "A"
  ttl     = "300"
  records = [data.terraform_remote_state.infrastructure.outputs.haproxy_gateway_private_ip]
}
resource "aws_route53_record" "bofapi-gateway-private" {
  zone_id = data.terraform_remote_state.infrastructure.outputs.private_zone_id
  name    = var.bofapi_name
  type    = "A"
  ttl     = "300"
  records = [data.terraform_remote_state.infrastructure.outputs.haproxy_gateway_private_ip]
}

resource "kubernetes_secret" "wso2-is-admin-creds" {
  metadata {
    name = "wso2-is-admin-creds"
    namespace = "mojaloop"
  }

  data = {
    username = "admin"
    password = vault_generic_secret.wso2_admin_password.data.value
  }

  type = "kubernetes.io/basic-auth"
  provider = kubernetes.k8s-gateway
  depends_on = [helm_release.mojaloop]
}

resource "helm_release" "bof-crds" {
  name       = "bof-crds"
  chart = "./k8s-manifests"
  namespace  = "mojaloop"
  timeout    = 300
  provider = helm.helm-gateway
  depends_on = [helm_release.mojaloop]
}

resource "helm_release" "bof-rules" {
  name       = "bof-oathkeeper-rules"
  chart      = "${var.project_root_path}/bof-custom-resources/oathkeeper-rules"
  namespace  = "mojaloop"
  timeout    = 300
  provider   = helm.helm-gateway
  force_update = true
  set {
    name  = "base_domain"
    value = data.terraform_remote_state.infrastructure.outputs.private_subdomain
    type  = "string"
  }
  set {
    name  = "bof_release_name"
    value = "bof"
    type  = "string"
  }
  set {
    name  = "moja_release_name"
    value = "moja"
    type  = "string"
  }
  depends_on = [helm_release.oathkeeper-maester]
}
