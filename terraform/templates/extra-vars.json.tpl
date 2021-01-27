{
  "docker_insecure_registries": [
    "${nexus_fqdn}:${nexus_docker_repo_listening_port}"
  ],
  "docker_registry_mirrors": [
    "http://${nexus_fqdn}:${nexus_docker_repo_listening_port}"
  ]
}