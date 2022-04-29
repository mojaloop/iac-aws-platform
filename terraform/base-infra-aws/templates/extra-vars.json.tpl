{
  "docker_insecure_registries": [
    "${nexus_ip}:${nexus_port}"
  ],
  "docker_registry_mirrors": [
    "http://${nexus_ip}:${nexus_port}"
  ],
  "apiserver_loadbalancer_domain_name": "${apiserver_loadbalancer_domain_name}",
  "kube_oidc_auth": "${kube_oidc_enabled}",
  "kube_oidc_url": "${kube_oidc_url}",
  "kube_oidc_client_id": "${kube_oidc_client_id}",
  "kube_oidc_groups_claim": "${groups_name}"
}