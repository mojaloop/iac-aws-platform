data "kubernetes_secret" "wildcard-secret" {
  metadata {
    name      = data.terraform_remote_state.vault.outputs.int_wildcard_cert_sec_name
    namespace = "default"
  }
  provider   = kubernetes.k8s-gateway
}

resource "kubernetes_secret" "local-wildcard-secret" {
  metadata {
    name = "local-wildcard-secret"
    namespace = "mojaloop"
  }

  data = {
    "tls.crt" = data.kubernetes_secret.wildcard-secret.data["tls.crt"]
    "tls.key" = data.kubernetes_secret.wildcard-secret.data["tls.key"]
  }

  type = "kubernetes.io/tls"
  provider = kubernetes.k8s-gateway
  depends_on = [helm_release.mojaloop]
}

/* resource "kubernetes_service_v1" "ext-oauth-svc" {
  metadata {
    name = "ext-oauth-svc"
    namespace = "mojaloop"
  }
  spec {
    external_name = "keycloak-oauth2-proxy.default.svc.cluster.local" 
    type = "ExternalName"
  }
  provider = kubernetes.k8s-gateway
  depends_on = [helm_release.mojaloop]
} */

resource "kubernetes_ingress_v1" "wso2-ml-ingress-secure" {
  metadata {
    name      = "wso2-ml-ingress-secure"
    namespace = "mojaloop"
    annotations = {
      "kubernetes.io/ingress.class" = "nginx-ext"
      "nginx.ingress.kubernetes.io/auth-url" = "http://oathkeeper-keycloak-api.keycloak.svc.cluster.local:4456/decisions$request_uri"
      #"nginx.ingress.kubernetes.io/auth-signin" = "https://oauth.${data.terraform_remote_state.infrastructure.outputs.public_subdomain}/oauth2/start?rd=$scheme://$best_http_host$request_uri"
      "nginx.ingress.kubernetes.io/auth-response-headers" = "Authorization"
      "nginx.ingress.kubernetes.io/proxy-buffer-size" = "16k"
      "nginx.ingress.kubernetes.io/whitelist-source-range" = "0.0.0.0/0"
    }
  }
  spec {
    rule {
      host = "interop-switch.${data.terraform_remote_state.infrastructure.outputs.public_subdomain}"

      http {
        path {
          backend {
            service {
              name = "${var.helm_mojaloop_release_name}-account-lookup-service"
              port {
                number = 80
              }
            }  
          }
          path = "/participants"
        }
        path {
          backend {
            service {
              name = "${var.helm_mojaloop_release_name}-account-lookup-service"
              port {
                number = 80
              }
            }
          }  
          path = "/parties"
        }
        path {
          backend {
            service {
              name = "${var.helm_mojaloop_release_name}-quoting-service"
              port {
                number = 80
              }
            }  
          }
          path = "/quotes"
        }
        path {
          backend {
            service {
              name = "${var.helm_mojaloop_release_name}-ml-api-adapter-service"
              port {
                number = 80
              }
            }  
          }
          path = "/transfers"
        }
        path {
          backend {
            service {
              name = "${var.helm_mojaloop_release_name}-bulk-quoting-service"
              port {
                number = 80
              }
            }  
          }
          path = "/bulkQuotes"
        }
        path {
          backend {
            service {
              name = "${var.helm_mojaloop_release_name}-transaction-requests-service"
              port {
                number = 80
              }
            }  
          }
          path = "/transactionRequests"
        }
        path {
          backend {
            service {
              name = "${var.helm_mojaloop_release_name}-transaction-requests-service"
              port {
                number = 80
              }
            }  
          }
          path = "/authorizations"
        }
      }
    }
    tls {
      hosts = ["interop-switch.${data.terraform_remote_state.infrastructure.outputs.public_subdomain}"]
      secret_name = kubernetes_secret.local-wildcard-secret.metadata[0].name
    }
  }
  provider   = kubernetes.k8s-gateway
  depends_on = [helm_release.mojaloop]
}
/* resource "kubernetes_ingress_v1" "wso2-ml-ingress-oauth" {
  metadata {
    name      = "wso2-ml-ingress-oauth"
    namespace = "mojaloop"
    annotations = {
      "kubernetes.io/ingress.class" = "nginx-ext"
    }
  }
  spec {
    rule {
      host = "interop-switch.${data.terraform_remote_state.infrastructure.outputs.public_subdomain}"

      http {
        
        path {
          backend {
            service {
              name = kubernetes_service_v1.ext-oauth-svc.metadata[0].name
              port {
                number = 80
              }
            }  
          }
          path = "/oauth2"
        }
      }
    }
    tls {
      hosts = ["interop-switch.${data.terraform_remote_state.infrastructure.outputs.public_subdomain}"]
      secret_name = kubernetes_secret.local-wildcard-secret.metadata[0].name
    }
  }
  provider   = kubernetes.k8s-gateway
  depends_on = [helm_release.mojaloop]
} */