ingress:
  enabled: true
  annotations:
    kubernetes.io/ingress.class: nginx
  hosts:
    - host: ${ingress_host}
      paths: ['/']
global:
  storageClass: ${storage_class}