resource "helm_release" "kafka" {
  for_each    = {for stateful_resource in var.stateful_resources : stateful_resource.resource_name => stateful_resource if stateful_resource.enabled && stateful_resource.local_resource != null && stateful_resource.local_resource.kafka_data != null}
  name       = each.value.resource_name
  repository = each.value.local_resource.resource_helm_repo
  chart      = each.value.local_resource.resource_helm_chart
  version    = each.value.local_resource.resource_helm_chart_version
  namespace  = each.value.resource_namespace
  create_namespace = true
  values = [
    templatefile("${path.module}/templates/${each.value.local_resource.resource_helm_values_ref}", {
      storage_size = each.value.local_resource.kafka_data.storage_size
      storage_class_name = var.storage_class_name
      name_override = each.value.resource_name
      svc_endpoint = each.value.logical_service_name
      service_port = each.value.local_resource.kafka_data.service_port
    })
  ]
  provider = helm.helm-gateway
}