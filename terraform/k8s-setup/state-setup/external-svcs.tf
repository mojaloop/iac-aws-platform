resource "kubernetes_namespace" "namespace-stateful-services" {
  metadata {
   name = "stateful-services"
  }
  provider = kubernetes.k8s-gateway

}

resource "kubernetes_service" "external-stateful-services" {
  for_each    = {for stateful_resource in var.stateful_resources : stateful_resource.resource_name => stateful_resource }
  metadata {
    name = each.value.logical_service_name
    namespace = kubernetes_namespace.namespace-stateful-services.metadata[0].name
  }
  spec {
    type = "ExternalName"
    external_name = each.value.local_resource != null ? "${each.value.resource_name}.${each.value.resource_namespace}.svc.cluster.local" : each.value.external_service.external_endpoint
  }
  provider = kubernetes.k8s-gateway
}