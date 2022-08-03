output "sg_id" {
  description = "Security group ID used for this environment"
  value       = aws_security_group.internet.id
}

output "internal_load_balancer_dns" {
  value = aws_lb.internal-lb.dns_name
}

output "external_load_balancer_dns" {
  value = aws_lb.external-lb.dns_name
}

output "k8s_master_nodes_private_ip" {
  value = module.k8-cluster-main.master_nodes_private_ip
}
output "k8s_master_nodes_private_dns" {
  value = module.k8-cluster-main.master_nodes_private_dns
}

output "k8s_worker_nodes_private_ip" {
  value = module.k8-cluster-main.worker_nodes_private_ip
}

output "k8s_worker_nodes_private_dns" {
  value = module.k8-cluster-main.worker_nodes_private_dns
}

output "interop_switch_private_fqdn" {
  description = "FQDN for the private hostname of the Mojaloop switch."
  value       = join(".", ["interop-switch", trimsuffix(aws_route53_zone.main_private.name, ".")])
}

output "private_subdomain" {
  value = aws_route53_zone.main_private.name
}

output "public_subdomain_zone_id" {
  value = aws_route53_zone.public_subdomain.zone_id
}

output "private_zone_id" {
  value = aws_route53_zone.main_private.zone_id
}

output "public_subdomain" {
  value = aws_route53_zone.public_subdomain.name
}

output "environment" {
  description = "Name of the environment built"
  value       = var.environment
}

output "perm1" {
  description = "Name of the environment built"
  value       = local.worker_kube_ec2_config
}
output "perm2" {
  description = "Name of the environment built"
  value       = local.master_kube_ec2_config
}

output "available_zones" {
  description = "available azs at time of infra build"
  value       = local.availability_zones
}