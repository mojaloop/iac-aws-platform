
imagePullCredentials:
  user: ${private_registry_user}
  pass: ${private_registry_pw}
  registry: ${private_registry_repo}
ingress:
  enabled: true
  annotations: {}
    # kubernetes.io/ingress.class: nginx
    # kubernetes.io/tls-acme: "true"
  hosts:
    - host: ${ingress_host}
      paths: ['/']