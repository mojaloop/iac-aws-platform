output "haproxy_id" {
  value = var.haproxy_enabled ? element(concat(aws_instance.haproxy.*.id, [""]), 0) : "HAPROXY_NOT_USED"
}

output "haproxy_private_ip" {
  value = var.haproxy_enabled ? element(concat(aws_instance.haproxy.*.private_ip, [""]),  0) : "HAPROXY_NOT_USED"
}

output "worker_nodes_private_ip" {
  value = aws_instance.k8s-worker.*.private_ip
}

output "worker_nodes_private_dns" {
  value = aws_instance.k8s-worker.*.private_dns
}

output "master_nodes_private_dns" {
  value = aws_instance.k8s-master.*.private_dns
}

output "master_nodes_private_ip" {
  value = aws_instance.k8s-master.*.private_ip
}
