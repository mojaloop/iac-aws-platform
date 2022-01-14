## Installation
# helm upgrade bof ./mojaloop/bof --install

# Default values for bof.
# This is a YAML-formatted file.
# Declare variables to be passed into your templates.

global:
  adminApiSvc:
    host: ${central_admin_host}
    port: 80
  settlementSvc:
    host: ${central_settlements_host}
    port: 80
  keto:
    readURL: "http://keto-read:80"
    writeURL: "http://keto-write:80"
  wso2:
    identityServer:
      userListURL: "${wso2_host}/scim2/Users"
      user: 'admin'
      secret:
        name: wso2-is-admin-creds
        key: password
  reportingDB:
    host: ${reporting_db_host}
    port: ${reporting_db_port}
    user: ${reporting_db_user}
    database: ${reporting_db_database}
    secret:
      name: ${reporting_db_secret_name}
      key: ${reporting_db_secret_key}
  reportingEventsDB:
    host: reporting-events-db
    port: 27017
    user: user
    database: default
    secret:
      name: reporting-events-db
      key: mongodb-password
  kafka:
    host: ${kafka_host}
    port: 9092
  mojalooprole: {}

## Backend API services
role-assignment-service:
  enabled: true
  ingress:
    enabled: false
    hostname: ${api_fqdn}
    path: /iam(/|$)(.*)
    annotations:
      nginx.ingress.kubernetes.io/rewrite-target: /$2
  configFiles:
    default.json: {
        "ROLES_LIST": [
          "manager",
          "operator",
          "clerk",
          "financeManager",
          "dfspReconciliationReports",
          "audit"
        ]
      }

reporting-hub-bop-api-svc:
  enabled: true
  ingress:
    enabled: false
    hostname: ${api_fqdn}
    path: /transfers(/|$)(.*)
    annotations:
      nginx.ingress.kubernetes.io/rewrite-target: /$2

reporting-legacy-api:
  enabled: true
  ingress:
    enabled: false
    hostname: ${api_fqdn}
    path: /reports(/|$)(.*)
    annotations:
      nginx.ingress.kubernetes.io/rewrite-target: /$2
  install-templates: true
  auth: true

## Front-end UI services
### Shell and helper UI services
reporting-hub-bop-shell:
  enabled: true
  ingress:
    hostname: ${portal_fqdn}
  config:
    env:
      AUTH_MOCK_API: false
      REMOTE_API_BASE_URL: /
      REMOTE_MOCK_API: false
      LOGIN_URL: /kratos/self-service/registration/browser
      LOGOUT_URL: /kratos/self-service/browser/flows/logout
      AUTH_TOKEN_URL: /kratos/sessions/whoami
      AUTH_ENABLED: true
      REMOTE_1_URL: http://${iamui_fqdn}
      REMOTE_2_URL: http://${transfersui_fqdn}
      REMOTE_3_URL: http://${settlementsui_fqdn}
      REMOTE_4_URL: http://${positionsui_fqdn}

security-hub-bop-kratos-ui:
  enabled: true
  config:
    env:
      ROCKET_PORT: 8000
      ROCKET_REGISTRATION_ENDPOINT: "http://kratos-public/self-service/registration/flows"
  service:
    internalPort: 8000
  ingress:
    hostname: ${portal_fqdn}
    pathType: ImplementationSpecific
    path: /selfui/auth(/|$)(.*)
    annotations:
      nginx.ingress.kubernetes.io/rewrite-target: /$2

### Micro-frontends
reporting-hub-bop-role-ui:
  enabled: true
  ingress:
    enabled: true
    pathType: ImplementationSpecific
    hostname: ${iamui_fqdn}
    path: /
  config:
    env:
      REACT_APP_API_BASE_URL: http://${portal_fqdn}/proxy/iam
      REACT_APP_MOCK_API: false


reporting-hub-bop-trx-ui:
  enabled: true
  ingress:
    enabled: true
    pathType: ImplementationSpecific
    hostname: ${transfersui_fqdn}
  config:
    env:
      REACT_APP_API_BASE_URL: http://${portal_fqdn}/proxy/transfers
      REACT_APP_MOCK_API: false

reporting-hub-bop-settlements-ui:
  enabled: true
  config:
    env:
      CENTRAL_LEDGER_ENDPOINT: http://${portal_fqdn}/proxy/central-admin
      CENTRAL_SETTLEMENTS_ENDPOINT: http://${portal_fqdn}/proxy/central-settlements
  ingress:
    enabled: true
    pathType: ImplementationSpecific
    hostname: ${settlementsui_fqdn}

reporting-hub-bop-positions-ui:
  enabled: true
  config:
    env:
      CENTRAL_LEDGER_ENDPOINT: http://${portal_fqdn}/proxy/central-admin
  ingress:
    enabled: true
    pathType: ImplementationSpecific
    hostname: ${positionsui_fqdn}

## Other services
security-role-perm-operator-svc:
  enabled: true
  installCRDs: false

reporting-events-processor-svc:
  enabled: true
  kafka:
    topic: topic-event
    consumerGroup: group
    clientId: client-id