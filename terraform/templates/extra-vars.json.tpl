{
  "docker_insecure_registries": [
    "${nexus_ip}:${nexus_port}"
  ],
  "docker_registry_mirrors": [
    "http://${nexus_ip}:${nexus_port}"
  ]
}