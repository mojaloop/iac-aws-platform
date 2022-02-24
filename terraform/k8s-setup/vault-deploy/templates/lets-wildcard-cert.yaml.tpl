apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: wildcard-cert-internal
  namespace: default
spec:
  secretName: ${secret_name}
  issuerRef:
    name: ${issuer_name}
    kind: ClusterIssuer
  commonName: ${domain_name}
  dnsNames:
    - ${domain_name}
    - "*.${domain_name}"