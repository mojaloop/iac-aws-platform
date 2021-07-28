ingress:
  enabled: true
  annotations: {}
    # kubernetes.io/ingress.class: nginx
    # kubernetes.io/tls-acme: "true"
  hosts:
    - host: ${ingress_host}
      paths: 
      - path: "/"

dbHost: ${db_host}
dbUser: ${db_user}
dbPassword: ${db_password}