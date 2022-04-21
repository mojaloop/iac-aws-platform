ingress:
  enabled: true
  annotations:
    kubernetes.io/ingress.class: nginx
  hosts:
    - host: ${ingress_host}
      paths: ['/']
global:
  storageClass: ${storage_class}

mariadb:
  nameOverride: ${service_name}-db
  fullnameOverride: ${service_name}-db

nameOverride: ${service_name}
fullnameOverride: ${service_name}

env:
  oracleType: ALIAS
  prefixLength: 3
  database:
    dbHost: ${service_name}-db
