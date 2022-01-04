output "sg_id" {
  description = "Security group ID used for this environment"
  value       = aws_security_group.internet.id
}

output "internal_load_balancer_dns" {
  value = module.nlb_int.private_dns
}

output "external_load_balancer_dns" {
  value = module.nlb_ext.public_dns
}

output "gateway_k8s_master_nodes_private_ip" {
  value = module.k8-cluster-gateway.master_nodes_private_ip
}
output "gateway_k8s_master_nodes_private_dns" {
  value = module.k8-cluster-gateway.master_nodes_private_dns
}

output "gateway_k8s_worker_nodes_private_ip" {
  value = module.k8-cluster-gateway.worker_nodes_private_ip
}

output "gateway_k8s_worker_nodes_private_dns" {
  value = module.k8-cluster-gateway.worker_nodes_private_dns
}

/* output "mcm_fqdn" {
  description = "FQDN for the public hostname of the Connection Manager service."
  value       = aws_route53_record.mcmweb-public.fqdn
}

output "extgw_public_fqdn" {
  description = "FQDN for the public hostname of the External GW service."
  value       = aws_route53_record.extgw-public.fqdn
}

output "intgw_public_fqdn" {
  description = "FQDN for the public hostname of the Internal GW service."
  value       = aws_route53_record.intgw-public.fqdn
}

output "intgw_private_fqdn" {
  description = "FQDN for the private hostname of the Internal GW service."
  value       = aws_route53_record.intgw-private.fqdn
}

output "iskm_public_fqdn" {
  description = "FQDN for the public hostname of the ISKM service."
  value       = aws_route53_record.iskm-public.fqdn
}

output "iskm_private_fqdn" {
  description = "FQDN for the private hostname of the ISKM service."
  value       = aws_route53_record.iskm-private.fqdn
} */

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

 output "finance_portal_fqdn" {
  description = "FQDN for the private hostname of the Mojaloop switch."
  value       = join(".", ["finance-portal", trimsuffix(aws_route53_zone.main_private.name, ".")])
}
/*output "grafana-services-private-fqdn" {
  description = "FQDN for the private hostname of grafana in the sup svcs cluster."
  value       = aws_route53_record.grafana-services-private.fqdn
}
output "prometheus-services-private-fqdn" {
  description = "FQDN for the private hostname of prometheus in the sup svcs cluster."
  value       = aws_route53_record.prometheus-services-private.fqdn
} */
