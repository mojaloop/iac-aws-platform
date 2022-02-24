apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: ${secret_name}
spec:
  secretName: ${secret_name}
  duration: 2160h # 90d
  renewBefore: 360h # 15d
  privateKey:
    algorithm: RSA
    encoding: PKCS1
    size: 4096
  usages:
    - digital signature
    - key encipherment
    - client auth
  commonName: ${domain_name}
  dnsNames: 
  - ${domain_name}
  issuerRef:
    name: ${issuer_name}
    kind: ClusterIssuer
    group: cert-manager.io