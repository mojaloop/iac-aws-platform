ingress:
  enabled: true
  annotations: {}
    # kubernetes.io/ingress.class: nginx
    # kubernetes.io/tls-acme: "true"
  externalHostname: ${ingress_host}
  loginService:
    name: ${mojaloop_release}-finance-portal
    portName: 3000
  settlementService:
    name: ${mojaloop_release}-centralsettlement-service
    portName: 80
  portalBackend:
    name: ${mojaloop_release}-finance-portal
    portName: 3000

imagePullCredentials:
  user: ${private_registry_user}
  pass: ${private_registry_pw}
  registry: ${private_registry_reg}

image:
  tag: ${image_tag}

env:
  PROXY_API_URL: http://${fin_portal_backend_svc}
  PROXY_TOKEN_URL: http://${fin_portal_backend_svc}/token
