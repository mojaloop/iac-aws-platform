global:
  config:
    db_password: "${mysql_password}"
    forensicloggingsidecar_disabled: true

account-lookup-service:
  account-lookup-service:
    containers:
      api:
        image:
          repository: mojaloop/account-lookup-service
          tag: v11.7.2
    config:
      db_password: "${mysql_password}"
    ingress:
      hosts:
        - account-lookup-service.${env}.${name}.${domain}.internal
    mysql:
      enabled: true
      mysqlPassword: "${mysql_password}"
      mysqlRootPassword: ${mysql_root_password}
  account-lookup-service-admin:
    containers:
      admin:
        image:
          repository: mojaloop/account-lookup-service
          tag: v11.7.2
    config:
      db_password: "${mysql_password}"
    ingress:
      hosts:
        - account-lookup-service-admin.${env}.${name}.${domain}.internal
  mysql:
    mysqlPassword: "${mysql_password}"
als-oracle-pathfinder:
  enabled: false
  config:
    db:
      account_lookup:
        password: "${mysql_password}"
      central_ledger:
        password: "${mysql_password}"
central:
  centraleventprocessor:
    ingress:
      hosts:
        api: central-event-processor.${env}.${name}.${domain}.internal
  centralledger:
    centralledger-handler-admin-transfer:
      config:
        db_password: "${mysql_password}"
      ingress:
        hosts:
          api: central-ledger-admin-transfer.${env}.${name}.${domain}.internal
    centralledger-handler-timeout:
      config:
        db_password: "${mysql_password}"
      ingress:
        hosts:
          api: central-ledger-timeout.${env}.${name}.${domain}.internal
    centralledger-handler-transfer-fulfil:
      config:
        db_password: "${mysql_password}"
      ingress:
        hosts:
          api: central-ledger-transfer-fulfil.${env}.${name}.${domain}.internal
    centralledger-handler-transfer-get:
      config:
        db_password: "${mysql_password}"
      ingress:
        hosts:
          api: central-ledger-transfer-get.${env}.${name}.${domain}.internal
    centralledger-handler-transfer-position:
      config:
        db_password: "${mysql_password}"
      ingress:
        hosts:
          api: central-ledger-transfer-position.${env}.${name}.${domain}.internal
    centralledger-handler-transfer-prepare:
      config:
        db_password: "${mysql_password}"
      ingress:
        hosts:
          api: central-ledger-transfer-prepare.${env}.${name}.${domain}.internal
    centralledger-service:
      config:
        db_password: "${mysql_password}"
      ingress:
        annotations:
          nginx.ingress.kubernetes.io/rewrite-target: /$2
        externalPath:
            api: /admin(/|$)(.*)
        hosts:
          api: interop-switch.${env}.${name}.${domain}.internal
          admin: interop-switch.${env}.${name}.${domain}.internal
        mysql:
    mysql:
      mysqlPassword: "${mysql_password}"
      mysqlRootPassword: ${mysql_root_password}
      persistence:
        enabled: true
        accessMode: ReadWriteOnce
        size: 8Gi
        storageClass: slow
      configFiles:
        mysql_custom.cnf: |
          [mysqld]
          skip-name-resolve
    kafka:
      configurationOverrides:
        log.retention.hours: ${kafka.retention_hours}
      persistence:
        enabled: true
        size: ${kafka.storage_size}
        mountPath: ${kafka.mountPath}
        storageClass: ${kafka.storage_type}
  centralsettlement:
    centralsettlement-service:
      ingress:
        annotations:
          nginx.ingress.kubernetes.io/rewrite-target: /v2/$2
        externalPath: 
          api: /settlements(/|$)(.*)
        hosts:
          api: interop-switch.${env}.${name}.${domain}.internal
      config:
        db_password: "${mysql_password}"
    centralsettlement-handler-settlementwindow:
      config:
        db_password: "${mysql_password}"
    centralsettlement-handler-transfersettlement:
      config:
        db_password: "${mysql_password}"
    
emailnotifier:
  ingress:
    hosts:
      api: emailnotifier.${env}.${name}.${domain}.internal
ml-api-adapter:
  ml-api-adapter-handler-notification:
    ingress:
      hosts:
        api: ml-api-adapter-handler-notification.${env}.${name}.${domain}.internal
  ml-api-adapter-service:
    ingress:
      modernIngressController: true
      modernIngressControllerRegex: (/|$)(.*)
      annotations:
        nginx.ingress.kubernetes.io/rewrite-target: /$2
      hosts:
        api: ml-api-adapter.${env}.${name}.${domain}.internal
quoting-service:
  image:
    repository: mojaloop/quoting-service
    tag: v12.0.7
  sidecar:
    enabled: false
  config:
    simple_routing_mode_enabled: false
    log_transport: "console"
    log_level: "debug"
    db_password: "${mysql_password}"
  ingress:
    hosts:
      api: quoting-service.${env}.${name}.${domain}.internal

mojaloop-simulator:
  enabled: true

simulator:
  ingress:
    hosts:
      - moja-simulator.${env}.${name}.${domain}.internal

finance-portal:
  config:
    db_password: "${mysql_password}"
    centralSettlementsEndpoint: '$release_name-centralsettlement-service/v2'
    oauthServer: ${wso2is_host}
    oauthClientKey: ${portal_oauth_app_id}
    oauthClientSecret: ${portal_oauth_app_token}
    BypassAuth: false
    InsecureCookie: true
  backend:
    image:
      tag: v15.2.0
    init:
      enabled: false
    ingress:
      enabled: true
      externalPath: /admin-portal-backend(/|$)(.*)
      hosts:
        api: finance-portal.${env}.${name}.${domain}.internal
      annotations:
        nginx.ingress.kubernetes.io/rewrite-target: /$2
  frontend: 
    ingress:
      enabled: true
      hosts:
        api: finance-portal.${env}.${name}.${domain}.internal
      annotations:
        nginx.ingress.kubernetes.io/rewrite-target: ""
finance-portal-settlement-management:
  enabled: false
  config:
    db_password: "${mysql_password}"

mojaloop-bulk:
  enabled: true  
  bulk-centralledger:
    cl-handler-bulk-transfer-get:
      config:
        db_password: "${mysql_password}"
    cl-handler-bulk-transfer-prepare:
      config:
        db_password: "${mysql_password}"
    cl-handler-bulk-transfer-fulfil:
      config:
        db_password: "${mysql_password}"
    cl-handler-bulk-transfer-processing:
      config:
        db_password: "${mysql_password}"
  bulk-api-adapter:
    bulk-api-adapter-service:
      ingress:
        hosts:
          api: bulk-api-adapter.${env}.${name}.${domain}.internal

ml-testing-toolkit:
  ml-testing-toolkit-backend:
    ingress:
      hosts:
        specApi:
          host: ttkbackend.${env}.${name}.${domain}.internal
          port: 5000
          paths: ['/']
        adminApi:
          host: ttkbackend.${env}.${name}.${domain}.internal
          port: 5050
          paths: ['/api/', '/socket.io/']
    config:
      user_config.json: {
        "VERSION": 1,
        "CALLBACK_ENDPOINT": "http://localhost:4000",
        "CALLBACK_RESOURCE_ENDPOINTS": {
          "enabled": true,
          "endpoints": [
            {
              "method": "put",
              "path": "/parties/{Type}/{ID}",
              "endpoint": "http://moja-account-lookup-service.demo"
            },
            {
              "method": "put",
              "path": "/quotes/{ID}",
              "endpoint": "http://moja-quoting-service.demo"
            },
            {
              "method": "put",
              "path": "/transfers/{ID}",
              "endpoint": "http://moja-ml-api-adapter-service.demo"
            }
          ]
        },
        "HUB_ONLY_MODE": false,
        "ENDPOINTS_DFSP_WISE": {
          "dfsps": {
            "userdfsp": {
              "defaultEndpoint": "http://scheme-adapter:4000",
              "endpoints": []
            },
            "userdfsp2": {
              "defaultEndpoint": "http://scheme-adapter2:4000",
              "endpoints": []
            }
          }
        },
        "SEND_CALLBACK_ENABLE": true,
        "FSPID": "testingtoolkitdfsp",
        "DEFAULT_USER_FSPID": "userdfsp",
        "TRANSFERS_VALIDATION_WITH_PREVIOUS_QUOTES": true,
        "TRANSFERS_VALIDATION_ILP_PACKET": true,
        "TRANSFERS_VALIDATION_CONDITION": true,
        "ILP_SECRET": "secret",
        "VERSIONING_SUPPORT_ENABLE": true,
        "VALIDATE_INBOUND_JWS": false,
        "VALIDATE_INBOUND_PUT_PARTIES_JWS": false,
        "JWS_SIGN": false,
        "JWS_SIGN_PUT_PARTIES": false,
        "INBOUND_MUTUAL_TLS_ENABLED": false,
        "OUTBOUND_MUTUAL_TLS_ENABLED": false,
        "ADVANCED_FEATURES_ENABLED": true,
        "CALLBACK_TIMEOUT": 10000,
        "LOG_SERVER_UI_URL": "${kibana_url}"
      }
      system_config.json: {
        "API_PORT": 5000,
        "HOSTING_ENABLED": false,
        "CONFIG_VERSIONS": {
          "response": 1,
          "callback": 1,
          "validation": 1,
          "forward": 1,
          "userSettings": 1
        },
        "DB": {
          "URI": "mongodb://ttk:ttk@$mongodb_host:$mongodb_port/ttk"
        },
        "OAUTH": {
          "AUTH_ENABLED": false,
          "APP_OAUTH_CLIENT_KEY": "ttk",
          "APP_OAUTH_CLIENT_SECRET": "23b898a5-63d2-4055-bbe1-54efcda37e7d",
          "MTA_ROLE": "Application/MTA",
          "PTA_ROLE": "Application/PTA",
          "EVERYONE_ROLE": "Internal/everyone",
          "P12_PASS_PHRASE": "SOME_S3C4R3_P@SS",
          "OAUTH2_TOKEN_ISS": "http://$auth_host:$auth_port$auth_token_iss_path",
          "OAUTH2_ISSUER": "http://$auth_host:$auth_port$auth_issuer_path",
          "JWT_COOKIE_NAME": "TTK-API_ACCESS_TOKEN",
          "EMBEDDED_CERTIFICATE": "$auth_embedded_certificate"
        },
        "KEYCLOAK": {
          "ENABLED": false,
          "API_URL": "http://$auth_host:$auth_port",
          "REALM": "testingtoolkit",
          "USERNAME": "hub",
          "PASSWORD": "hub"
        },
        "SERVER_LOGS": {
          "ENABLED": true,
          "RESULTS_PAGE_SIZE": 20,
          "ADAPTER": {
            "TYPE": "ELASTICSEARCH",
            "INDEX": "mojaloop*",
            "API_URL": "${elasticsearch_url}"
          }
        },
        "CONNECTION_MANAGER": {
          "API_URL": "http://$connection_manager_host:$connection_manager_port",
          "AUTH_ENABLED": false,
          "HUB_USERNAME": "hub",
          "HUB_PASSWORD": "hub"
        },
        "API_DEFINITIONS": [
          {
            "type": "fspiop",
            "version": "1.0",
            "folderPath": "fspiop_1.0",
            "asynchronous": true
          },
          {
            "type": "fspiop",
            "version": "1.1",
            "folderPath": "fspiop_1.1",
            "asynchronous": true
          },
          {
            "type": "settlements",
            "version": "1.0",
            "folderPath": "settlements_1.0"
          },
          {
            "type": "central_admin",
            "version": "9.3",
            "folderPath": "central_admin_9.3"
          },
          {
            "type": "als_admin",
            "version": "1.1",
            "folderPath": "als_admin_1.1"
          },
          {
            "type": "mojaloop_simulator",
            "version": "0.1",
            "folderPath": "mojaloop_simulator_0.1"
          }
        ]
      }
  ml-testing-toolkit-frontend:
    ingress:
      hosts:
        ui: 
          host: ttkfrontend.${env}.${name}.${domain}.internal
          port: 6060
          paths: ['/']
    config:
      API_BASE_URL: http://ttkbackend.${env}.${name}.${domain}.internal:30000

transaction-requests-service:
  ingress:
    hosts:
      api: transaction-request-service.${env}.${name}.${domain}.internal
