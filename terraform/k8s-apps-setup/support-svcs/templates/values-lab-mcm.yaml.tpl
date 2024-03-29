mysqlDatabase: mcm
mysqlUser: devdat1asql1
mysqlPassword: ${password}
mysqlRootPassword: ${root_password}
persistence:
  storageClass: ${storage_class_name}
  accessMode: ReadWriteOnce
  size: 8Gi


db:
  user: devdat1asql1
  password: ${password}
  host: mysql-mcm.mysql-mcm.svc.cluster.local
  port: 3306
  schema: mcm

api:
  url: https://${mcm_public_fqdn}
  extraTLS:
    rootCert:
      enabled: true
  wso2TokenIssuer:
    cert:
      enabled: true
  oauth:
    enabled: true
    issuer: https://${iskm_private_fqdn}/oauth2/token
    key: change_me_later
    secret: change_me_later
    resetPassword:
      issuer: https://${iskm_private_fqdn}/scim2/Users
      user: admin
      pass: ${admin_pw}
  auth2fa:
    enabled: false
  totp:
    admin:
      issuer: https://${iskm_private_fqdn}/services/TOTPAdminService
      user: admin
      password: ${admin_pw}
    label: MCM
    issuer: ${totp_issuer}
  wso2:
    manager:
      service:
        url: https://${iskm_private_fqdn}/services/RemoteUserStoreManagerService.RemoteUserStoreManagerServiceHttpsSoap12Endpoint
        user: admin
        pass: ${admin_pw}
  vault:
    auth:
      k8s:
        enabled: true
        token: /var/run/secrets/kubernetes.io/serviceaccount/token
        role: ${k8s_vault_role}
        mountPoint: ${k8s_auth_path}
    endpoint: ${vault_endpoint}
    mounts:
      pki: pki-root-ca
      intermediatePki: pki-int-ca
      kv: ${mcm_kv_secret_path}
    pkiBaseDomain: ${pki_base_domain}
    signExpiryHours: 43800
  serviceAccount:
    externallyManaged: true
    serviceAccountNameOverride: ${service_account_name}
  rbac:
    enabled: false
ui:
  oauth:
    enabled: true

ingress:
  enabled: true
  host: ${mcm_public_fqdn}
  tls:
    - hosts:
      - "*.${mcm_public_fqdn}"
  annotations:
    kubernetes.io/ingress.class: nginx-ext
    #cert-manager.io/cluster-issuer: letsencrypt
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
