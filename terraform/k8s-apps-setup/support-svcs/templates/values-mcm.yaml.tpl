db:
  user: ${db_user}
  password: ${db_password}
  host: ${db_host}
  port: ${db_port}
  schema: ${db_schema}

api:
  url: https://${mcm_public_fqdn}
  extraTLS:
    rootCert:
      enabled: false
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
  certManager:
    enabled: true
    serverCertSecretName: ${server_cert_secret_name}
    serverCertSecretNamespace: ${server_cert_secret_namespace}
  switchFQDN: ${switch_domain}
  vault:
    auth:
      k8s:
        enabled: true
        token: /var/run/secrets/kubernetes.io/serviceaccount/token
        role: ${k8s_vault_role}
        mountPoint: ${k8s_auth_path}
    endpoint: ${vault_endpoint}
    mounts:
      pki: ${pki_path}
      kv: ${mcm_kv_secret_path}
      dfspClientCertBundle: ${dfsp_client_cert_bundle}
      dfspInternalIPWhitelistBundle: ${dfsp_internal_whitelist_secret}
      dfspExternalIPWhitelistBundle: ${dfsp_external_whitelist_secret}
    pkiServerRole: ${pki_server_role}
    pkiClientRole: ${pki_client_role}
    signExpiryHours: 43800
  serviceAccount:
    externallyManaged: true
    serviceAccountNameOverride: ${service_account_name}
  rbac:
    enabled: false
  config:
    caCSRParametersData: |-
      {
        "ST": "",
        "C": "",
        "L": "",
        "O": "${env_o}",
        "CN": "${env_cn}",
        "OU": "${env_ou}"
      }
ui:
  oauth:
    enabled: true

ingress:
  enabled: true
  className: ${ingress_class}
  host: ${mcm_public_fqdn}
  tls:
    - hosts:
      - "*.${mcm_public_fqdn}"
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
    nginx.ingress.kubernetes.io/whitelist-source-range: "0.0.0.0/0"
