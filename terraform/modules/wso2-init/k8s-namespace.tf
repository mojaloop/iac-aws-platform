resource "kubernetes_namespace" "ns" {
  metadata {
    name = var.namespace
  }
}
