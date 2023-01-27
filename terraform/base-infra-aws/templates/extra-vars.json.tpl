{
  "containerd_insecure_registries": {
    "*": "http://${nexus_ip}:${nexus_port}"
  },
  "containerd_registries": {},
  "apiserver_loadbalancer_domain_name": "${apiserver_loadbalancer_domain_name}",
  "kube_oidc_auth": "${kube_oidc_enabled}",
  "kube_oidc_url": "${kube_oidc_url}",
  "kube_oidc_client_id": "${kube_oidc_client_id}",
  "kube_oidc_groups_claim": "${groups_name}",
  "argocd_enabled": "false"
}
