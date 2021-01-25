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
  url: http://${mcm_public_fqdn}:30000
  oauth:
    enabled: "TRUE"
    issuer: https://${iskm_private_fqdn}:9443/oauth2/token
    key: change_me_later
    secret: change_me_later
    resetPassword:
      issuer: https://${iskm_private_fqdn}:9443/scim2/Users
      user: admin
      pass: admin
  auth2fa:
    enabled: "TRUE"
  totp:
    admin:
      issuer: https://${iskm_private_fqdn}:9443/services/TOTPAdminService
      user: admin
      password: admin
    label: MCM
    issuer: ${totp_issuer}
  wso2:
    manager:
      service:
        url: https://${iskm_private_fqdn}:9443/services/RemoteUserStoreManagerService.RemoteUserStoreManagerServiceHttpsSoap12Endpoint
        user: admin
        pass: admin

ui:
  oauth:
    enabled: "TRUE"

host: ${mcm_public_fqdn}
