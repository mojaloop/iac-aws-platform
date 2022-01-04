ingress:
  enabled: true
  annotations:
    kubernetes.io/ingress.class: nginx
    cert-manager.io/cluster-issuer: letsencrypt
  hosts:
    - host: ${ingress_host}
      paths: 
      - path: "/"
  tls:
    - secretName: ml-rpting-tls
      hosts:
      - ${ingress_host}
dbHost: ${db_host}
dbUser: ${db_user}
dbPassword: ${db_password}