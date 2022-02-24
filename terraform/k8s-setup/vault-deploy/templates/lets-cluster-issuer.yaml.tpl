apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: ${issuer_name}
spec:
  acme:
    # You must replace this email address with your own.
    # Let's Encrypt will use this to contact you about expiring
    # certificates, and issues related to your account.
    email: ${letsencrypt_email}
    server: ${letsencrypt_server}
    privateKeySecretRef:
      # Secret resource that will be used to store the account's private key.
      name: letsencrypt-issuer-account-key
    solvers:
    - selector:
        dnsZones:
          - ${domain}
      dns01:
        route53:
          region: ${region}
          accessKeyID: ${external_dns_iam_access_key}
          secretAccessKeySecretRef:
            name: ${secret_name}
            key: secret-access-key