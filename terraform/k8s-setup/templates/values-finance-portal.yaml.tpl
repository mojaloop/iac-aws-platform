ingress:
  enabled: true
  annotations:
    kubernetes.io/ingress.class: nginx
    #cert-manager.io/cluster-issuer: letsencrypt
  externalHostname: ${ingress_host}
  tls:
    secretName: ""
  authService:
    name: ${mojaloop_release}-finance-portal
    portName: 3000
  ledgerService:
    name: ${mojaloop_release}-centralledger-service
    portName: 80
  settlementService:
    name: ${mojaloop_release}-centralsettlement-service
    portName: 80
  portalBackend:
    name: ${mojaloop_release}-finance-portal
    portName: 3000

image:
  tag: ${image_tag}

env:
  PROXY_API_URL: http://${fin_portal_backend_svc}
  PROXY_TOKEN_URL: http://${fin_portal_backend_svc}/token
