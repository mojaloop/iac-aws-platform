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
    host: ${reporting_events_mongodb_host}
    port: 27017
    user: ${reporting_events_mongodb_user}
    database: ${reporting_events_mongodb_database}
    secret:
      name: ${reporting_events_mongodb_secret_name}
      key: mongodb-passwords
  kafka:
    host: ${kafka_host}
    port: 9092
  mojalooprole: {}
  rolePermOperator:
    mojaloopRole: {}
    mojaloopPermissionExclusion: {}
    apiSvc: {}

## RBAC Tests
rbacTests:
  enabled: true
  command:
    - npm
    - run
    - test:rbac
    - --
    - --silent=false
  env:
    ROLE_ASSIGNMENT_SVC_BASE_PATH: http://${release_name}-role-assignment-service
    ML_INGRESS_BASE_PATH: https://${portal_fqdn}
    TEST_USER_NAME: ${test_user_name}
    TEST_USER_PASSWORD: ${test_user_password}

## Report Tests
reportTests:
  enabled: true
  command:
    - npm
    - run
    - test:report
    - --
    - --silent=false
  env:
    ROLE_ASSIGNMENT_SVC_BASE_PATH: http://${release_name}-role-assignment-service
    ML_INGRESS_BASE_PATH: https://${portal_fqdn}
    TEST_USER_NAME: ${test_user_name}
    TEST_USER_PASSWORD: ${test_user_password}
    CENTRAL_LEDGER_ADMIN_ENDPOINT: https://${portal_fqdn}/proxy/central-admin
    CENTRAL_SETTLEMENT_ENDPOINT: https://${portal_fqdn}/proxy/central-settlements
    REPORT_BASE_PATH: https://${portal_fqdn}/proxy/reports
    ACCOUNT_LOOKUP_SERVICE_BASE_PATH: http://${account_lookup_service_host}
    PAYER_BACKEND_BASE_PATH: http://${sim_payer_backend_host}:3003
    PAYEE_BACKEND_BASE_PATH: http://${sim_payee_backend_host}:3003
    TEST_PAYER: ${report_tests_payer}
    TEST_PAYEE: ${report_tests_payee}
    TEST_CURRENCY: ${report_tests_currency}
    TEST_PAYER_MSISDN: "17039811901"
    TEST_PAYEE_MSISDN: "17039811902"
    TEST_SETTLEMENT_MODEL: DEFAULTDEFERREDNET
    NODE_TLS_REJECT_UNAUTHORIZED: "0"

## Backend API services
role-assignment-service:
  enabled: true
  ingress:
    enabled: false
    hostname: ${api_fqdn}
    path: /iam(/|$)(.*)
    annotations:
      kubernetes.io/ingress.class: nginx
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
      kubernetes.io/ingress.class: nginx
      nginx.ingress.kubernetes.io/rewrite-target: /$2

reporting-legacy-api:
  enabled: true
  ingress:
    enabled: false
    hostname: ${api_fqdn}
    path: /reports(/|$)(.*)
    annotations:
      kubernetes.io/ingress.class: nginx
      nginx.ingress.kubernetes.io/rewrite-target: /$2
  install-templates: true
  auth: true
  config:
    env:
      VALIDATION_RETRY_COUNT: "10"
      VALIDATION_RETRY_INTERVAL_MS: "5000"
  reporting-k8s-templates:
    templates:
    %{ for config_key, config_value in mojaloop_reports_config.defaultReports }
      ${config_key}: ${config_value}
    %{ endfor }

## Front-end UI services
### Shell and helper UI services
reporting-hub-bop-shell:
  enabled: true
  ingress:
    hostname: ${portal_fqdn}
    annotations:
      kubernetes.io/ingress.class: nginx
      #cert-manager.io/cluster-issuer: letsencrypt
    tls: true
    selfSigned: true
    tlsSetSecretManual: true
    tlsManualSecretName: ""
  config:
    env:
      AUTH_MOCK_API: false
      REMOTE_API_BASE_URL: /
      REMOTE_MOCK_API: false
      LOGIN_URL: /kratos/self-service/registration/browser
      LOGOUT_URL: /kratos/self-service/browser/flows/logout
      AUTH_TOKEN_URL: /kratos/sessions/whoami
      AUTH_ENABLED: true
      REMOTE_1_URL: https://${iamui_fqdn}
      REMOTE_2_URL: https://${transfersui_fqdn}
      REMOTE_3_URL: https://${settlementsui_fqdn}
      REMOTE_4_URL: https://${positionsui_fqdn}

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
      kubernetes.io/ingress.class: nginx
      nginx.ingress.kubernetes.io/rewrite-target: /$2
      #cert-manager.io/cluster-issuer: letsencrypt
    tls: true
    selfSigned: true
    tlsSetSecretManual: true
    tlsManualSecretName: ""

### Micro-frontends
reporting-hub-bop-role-ui:
  enabled: true
  ingress:
    enabled: true
    pathType: ImplementationSpecific
    hostname: ${iamui_fqdn}
    path: /
    annotations:
      kubernetes.io/ingress.class: nginx
      #cert-manager.io/cluster-issuer: letsencrypt
    tls: true
    selfSigned: true
    tlsSetSecretManual: true
    tlsManualSecretName: ""
  config:
    env:
      REACT_APP_API_BASE_URL: https://${portal_fqdn}/proxy/iam
      REACT_APP_MOCK_API: false


reporting-hub-bop-trx-ui:
  enabled: true
  ingress:
    enabled: true
    pathType: ImplementationSpecific
    hostname: ${transfersui_fqdn}
    annotations:
      kubernetes.io/ingress.class: nginx
      #cert-manager.io/cluster-issuer: letsencrypt
    tls: true
    selfSigned: true
    tlsSetSecretManual: true
    tlsManualSecretName: ""
  config:
    env:
      REACT_APP_API_BASE_URL: https://${portal_fqdn}/proxy/transfers
      REACT_APP_MOCK_API: false

reporting-hub-bop-settlements-ui:
  ## Overriding the image version for bugfix related to https://modusbox.atlassian.net/browse/MBP-639
  image:
    registry: docker.io
    repository: mojaloop/reporting-hub-bop-settlements-ui
    tag: v0.0.17
  enabled: true
  config:
    env:
      CENTRAL_LEDGER_ENDPOINT: https://${portal_fqdn}/proxy/central-admin
      CENTRAL_SETTLEMENTS_ENDPOINT: https://${portal_fqdn}/proxy/central-settlements
      REPORTING_API_ENDPOINT: https://${portal_fqdn}/proxy/transfers
  ingress:
    enabled: true
    pathType: ImplementationSpecific
    hostname: ${settlementsui_fqdn}
    annotations:
      kubernetes.io/ingress.class: nginx
      #cert-manager.io/cluster-issuer: letsencrypt
    tls: true
    selfSigned: true
    tlsSetSecretManual: true
    tlsManualSecretName: ""

reporting-hub-bop-positions-ui:
  enabled: true
  config:
    env:
      CENTRAL_LEDGER_ENDPOINT: https://${portal_fqdn}/proxy/central-admin
  ingress:
    enabled: true
    pathType: ImplementationSpecific
    hostname: ${positionsui_fqdn}
    annotations:
      kubernetes.io/ingress.class: nginx
      #cert-manager.io/cluster-issuer: letsencrypt
    tls: true
    selfSigned: true
    tlsSetSecretManual: true
    tlsManualSecretName: ""

## Other services
# Exposing validation API for role permission validation from IaC
# The request should be as below
# curl -X POST /validate/role-permissions \
#  -H 'Content-Type: application/json' \
#  -H 'Accept: application/json' \
#  -d \
#  '{
#    "rolePermissions": [
#      {
#        "rolename": "string",
#        "permissions": [
#          "string"
#        ]
#      }
#    ],
#    "permissionExclusions": [
#      {
#        "permissionsA": [
#          "string"
#        ],
#        "permissionsB": [
#          "string"
#        ]
#      }
#    ]
#  }'
security-role-perm-operator-svc:
  enabled: true
  ingress:
    enabled: true
    hostname: ${api_fqdn}
    path: /operator(/validate/.*)
    annotations:
      kubernetes.io/ingress.class: nginx
      nginx.ingress.kubernetes.io/rewrite-target: $1
    tls: true
    selfSigned: true
    tlsSetSecretManual: true
    tlsManualSecretName: ""

reporting-events-processor-svc:
  enabled: true
  kafka:
    host: ${kafka_host}
    port: 9092
    topicEvent: topic-event
    consumerGroup: reporting_events_processor_consumer_group
    clientId: reporting_events_processor_consumer

reporting-hub-bop-experience-api-svc:
  enabled: true
