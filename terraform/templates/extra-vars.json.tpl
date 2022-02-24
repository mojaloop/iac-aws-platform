{
  "docker_insecure_registries": [
    "${nexus_ip}:${nexus_port}"
  ],
  "docker_registry_mirrors": [
    "http://${nexus_ip}:${nexus_port}"
  ],
  "apiserver_loadbalancer_domain_name": "${apiserver_loadbalancer_domain_name}"
}