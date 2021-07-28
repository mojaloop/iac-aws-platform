mysqlDatabase: mcm
mysqlUser: devdat1asql1
mysqlPassword: ${password}
mysqlRootPassword: ${root_password}
persistence:
  storageClass: slow
  accessMode: ReadWriteOnce
  size: 8Gi


db:
  user: devdat1asql1
  password: ${password}
  host: mysql-mcm.mysql-mcm.svc.cluster.local
  port: 3306
  schema: mcm

api:
  url: http://${mcm_public_fqdn}
  extraTLS:
    rootCert:
      enabled: true
  wso2TokenIssuer:
    cert:
      enabled: true
  oauth:
    enabled: true
    issuer: https://${iskm_private_fqdn}:9443/oauth2/token
    key: change_me_later
    secret: change_me_later
    resetPassword:
      issuer: https://${iskm_private_fqdn}:9443/scim2/Users
      user: admin
      pass: ${admin_pw}
  auth2fa:
    enabled: false
  totp:
    admin:
      issuer: https://${iskm_private_fqdn}:9443/services/TOTPAdminService
      user: admin
      password: ${admin_pw}
    label: MCM
    issuer: ${totp_issuer}
  wso2:
    manager:
      service:
        url: https://${iskm_private_fqdn}:9443/services/RemoteUserStoreManagerService.RemoteUserStoreManagerServiceHttpsSoap12Endpoint
        user: admin
        pass: ${admin_pw}
  env:
    # Name is mandatory- other details are optional. If name is omitted, no environment will be
    # created before the server starts.
    name: ${env_name}
    cn: ${env_cn}
    o: ${env_o}
    ou: ${env_ou}

ui:
  oauth:
    enabled: true

host: ${mcm_public_fqdn}
