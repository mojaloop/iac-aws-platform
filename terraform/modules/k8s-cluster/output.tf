output "worker_nodes_id" {
  value = [
    for worker in aws_instance.k8s-worker : worker.id
  ]
}

output "worker_nodes_private_ip" {
  value = [
    for worker in aws_instance.k8s-worker : worker.private_ip
  ]
}

output "worker_nodes_private_dns" {
  value = [
    for worker in aws_instance.k8s-worker : worker.private_dns
  ]
}

output "worker_nodes_availability_zones" {
  value = [
    for worker in aws_instance.k8s-worker : worker.availability_zone
  ]
}

output "master_nodes_id" {
  value = [
    for master in aws_instance.k8s-master : master.id
  ]
}

output "master_nodes_private_dns" {
  value = [
    for master in aws_instance.k8s-master : master.private_dns
  ]
}

output "master_nodes_private_ip" {
  value = [
    for master in aws_instance.k8s-master : master.private_ip
  ]
}

output "master_nodes" {
  value = aws_instance.k8s-master
}

output "worker_nodes" {
  value = aws_instance.k8s-worker
}

output "inventory_file_location" {
  value = "${path.module}/${var.inventory_file}"
}