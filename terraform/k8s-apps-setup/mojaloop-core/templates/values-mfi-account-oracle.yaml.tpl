ingress:
  enabled: true
  hosts:
    - host: ${ingress_host}
      paths: ['/']
global:
  storageClass: ${storage_class}

env:
  oracleType: ACCOUNT_ID
  prefixLength: 3
