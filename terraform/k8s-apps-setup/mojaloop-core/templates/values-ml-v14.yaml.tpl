# Custom YAML TEMPLATE Anchors
CONFIG:
  als_db_password: &ALS_DB_PASSWORD "${account_lookup_db_password}"
  als_db_host: &ALS_DB_HOST "${account_lookup_db_host}"
  als_db_user: &ALS_DB_USER "${account_lookup_db_user}"
  als_db_port: &ALS_DB_PORT ${account_lookup_db_port}
  als_db_database: &ALS_DB_DATABASE "${account_lookup_db_database}"
  cl_db_password: &CL_DB_PASSWORD "${central_ledger_db_password}"
  cl_db_host: &CL_DB_HOST "${central_ledger_db_host}"
  cl_db_user: &CL_DB_USER "${central_ledger_db_user}"
  cl_db_port: &CL_DB_PORT ${central_ledger_db_port}
  cl_db_database: &CL_DB_DATABASE "${central_ledger_db_database}"
  central_settlement_db_password: &CS_DB_PASSWORD "${central_settlement_db_password}"
  central_settlement_db_host: &CS_DB_HOST "${central_settlement_db_host}"
  central_settlement_db_user: &CS_DB_USER "${central_settlement_db_user}"
  central_settlement_db_port: &CS_DB_PORT ${central_settlement_db_port}
  central_settlement_db_database: &CS_DB_DATABASE "${central_settlement_db_database}"
  quoting_db_password: &QUOTING_DB_PASSWORD "${quoting_db_password}"
  quoting_db_host: &QUOTING_DB_HOST "${quoting_db_host}"
  quoting_db_user: &QUOTING_DB_USER "${quoting_db_user}"
  quoting_db_port: &QUOTING_DB_PORT ${quoting_db_port}
  quoting_db_database: &QUOTING_DB_DATABASE "${quoting_db_database}"
  kafka_host: &KAFKA_HOST "${kafka_host}"
  kafka_port: &KAFKA_PORT ${kafka_port}
  mongo_host: &MONGO_HOST "${cl_mongodb_host}"
  mongo_user: &MONGO_USER "${cl_mongodb_user}"
  mongo_password: &MONGO_PASSWORD "${cl_mongodb_pass}"
  mongo_database: &MONGO_DATABASE "${cl_mongodb_database}"
  mongo_port: &MONGO_PORT ${cl_mongodb_port}
  third_party_consent_db_host: &THIRD_PTY_CONSENT_HOST "${third_party_consent_db_host}"
  third_party_consent_db_user: &THIRD_PTY_CONSENT_USER "${third_party_consent_db_user}"
  third_party_consent_db_password: &THIRD_PTY_CONSENT_PASSWORD "${third_party_consent_db_password}"
  third_party_consent_db_database: &THIRD_PTY_CONSENT_DATABASE "${third_party_consent_db_database}"
  third_party_consent_db_port: &THIRD_PTY_CONSENT_PORT ${third_party_consent_db_port}
  third_party_auth_db_host: &THIRD_PTY_AUTH_HOST "${third_party_auth_db_host}"
  third_party_auth_db_user: &THIRD_PTY_AUTH_USER "${third_party_auth_db_user}"
  third_party_auth_db_password: &THIRD_PTY_AUTH_PASSWORD "${third_party_auth_db_password}"
  third_party_auth_db_database: &THIRD_PTY_AUTH_DATABASE "${third_party_auth_db_database}"
  third_party_auth_db_port: &THIRD_PTY_AUTH_PORT ${third_party_auth_db_port}
  third_party_auth_redis_host: &THIRD_PTY_AUTH_REDIS_HOST "${third_party_auth_redis_host}"
  third_party_auth_redis_port: &THIRD_PTY_AUTH_REDIS_PORT ${third_party_auth_redis_port}
  objstore_uri: &OBJSTORE_URI 'mongodb://${cl_mongodb_user}:${cl_mongodb_pass}@${cl_mongodb_host}:${cl_mongodb_port}/${cl_mongodb_database}'
  ingress_class: &INGRESS_CLASS "${ingress_class_name}"
  ## MOJALOOP-TTK-SIMULATORS Backend
  moja_ttk_sim_kafka_host: &MOJA_TTK_SIM_KAFKA_HOST "${kafka_host}"
  moja_ttk_sim_kafka_port: &MOJA_TTK_SIM_KAFKA_PORT ${kafka_port}
  moja_ttk_sim_redis_host: &MOJA_TTK_SIM_REDIS_HOST "${ttksims_redis_host}"
  moja_ttk_sim_redis_port: &MOJA_TTK_SIM_REDIS_PORT ${ttksims_redis_port}
global:
  config:
    forensicloggingsidecar_disabled: true

account-lookup-service:
  account-lookup-service:
    config:
      db_password: *ALS_DB_PASSWORD
      db_host: *ALS_DB_HOST
      db_user: *ALS_DB_USER
      db_port: *ALS_DB_PORT
      db_database: *ALS_DB_DATABASE
      endpointSecurity:
        jwsSigningKey: |-
          ${indent(10, jws_signing_priv_key)}
    # Thirdparty API Config
      featureEnableExtendedPartyIdType: ${mojaloop_thirdparty_support_enabled}
    ingress:
      enabled: true
      className: *INGRESS_CLASS
      hostname: account-lookup-service.${private_subdomain}
  account-lookup-service-admin:
    config:
      db_password: *ALS_DB_PASSWORD
      db_host: *ALS_DB_HOST
      db_user: *ALS_DB_USER
      db_port: *ALS_DB_PORT
      db_database: *ALS_DB_DATABASE
    # Thirdparty API Config
      featureEnableExtendedPartyIdType: ${mojaloop_thirdparty_support_enabled}
    ingress:
      enabled: true
      className: *INGRESS_CLASS
      hostname: account-lookup-service-admin.${private_subdomain}
  mysql:
    enabled: false
  als-oracle-pathfinder:
    enabled: false
central:
  centraleventprocessor:
    mongodb:
      enabled: false
    config:
      kafka_host: *KAFKA_HOST
      kafka_port: *KAFKA_PORT
      mongo_host: *MONGO_HOST
      mongo_port: *MONGO_PORT
      mongo_user: *MONGO_USER
      mongo_password: *MONGO_PASSWORD
      mongo_database: *MONGO_DATABASE
    ingress:
      enabled: true
      className: *INGRESS_CLASS
      hostname: central-event-processor.${private_subdomain}
  centralledger:
    centralledger-handler-admin-transfer:
      config:
        kafka_host: *KAFKA_HOST
        kafka_port: *KAFKA_PORT
        db_password: *CL_DB_PASSWORD
        db_host: *CL_DB_HOST
        db_user: *CL_DB_USER    
        db_port: *CL_DB_PORT
        db_database: *CL_DB_DATABASE
      ingress:
        enabled: true
        className: *INGRESS_CLASS
        hostname: central-ledger-admin-transfer.${private_subdomain}
    centralledger-handler-timeout:
      config:
        kafka_host: *KAFKA_HOST
        kafka_port: *KAFKA_PORT
        db_password: *CL_DB_PASSWORD
        db_host: *CL_DB_HOST
        db_user: *CL_DB_USER
        db_port: *CL_DB_PORT
        db_database: *CL_DB_DATABASE
      ingress:
        enabled: true
        className: *INGRESS_CLASS
        hostname: central-ledger-timeout.${private_subdomain}
    centralledger-handler-transfer-fulfil:
      config:
        kafka_host: *KAFKA_HOST
        kafka_port: *KAFKA_PORT
        db_password: *CL_DB_PASSWORD
        db_host: *CL_DB_HOST
        db_user: *CL_DB_USER
        db_port: *CL_DB_PORT
        db_database: *CL_DB_DATABASE
      ingress:
        enabled: true
        className: *INGRESS_CLASS
        hostname: central-ledger-transfer-fulfil.${private_subdomain}
    centralledger-handler-transfer-get:
      config:
        kafka_host: *KAFKA_HOST
        kafka_port: *KAFKA_PORT
        db_password: *CL_DB_PASSWORD
        db_host: *CL_DB_HOST
        db_user: *CL_DB_USER
        db_port: *CL_DB_PORT
        db_database: *CL_DB_DATABASE
      ingress:
        enabled: true
        className: *INGRESS_CLASS
        hostname: central-ledger-transfer-get.${private_subdomain}
    centralledger-handler-transfer-position:
      config:
        kafka_host: *KAFKA_HOST
        kafka_port: *KAFKA_PORT
        db_password: *CL_DB_PASSWORD
        db_host: *CL_DB_HOST
        db_user: *CL_DB_USER
        db_port: *CL_DB_PORT
        db_database: *CL_DB_DATABASE
      ingress:
        enabled: true
        className: *INGRESS_CLASS
        hostname: central-ledger-transfer-position.${private_subdomain}
    centralledger-handler-transfer-prepare:
      config:
        kafka_host: *KAFKA_HOST
        kafka_port: *KAFKA_PORT
        db_password: *CL_DB_PASSWORD
        db_host: *CL_DB_HOST
        db_user: *CL_DB_USER
        db_port: *CL_DB_PORT        
        db_database: *CL_DB_DATABASE
      ingress:
        enabled: true
        className: *INGRESS_CLASS
        hostname: central-ledger-transfer-prepare.${private_subdomain}
    centralledger-service:
      config:
        kafka_host: *KAFKA_HOST
        kafka_port: *KAFKA_PORT
        db_password: *CL_DB_PASSWORD
        db_host: *CL_DB_HOST
        db_user: *CL_DB_USER
        db_port: *CL_DB_PORT        
        db_database: *CL_DB_DATABASE
      ingress:
        enabled: true
        className: *INGRESS_CLASS
        annotations:
          nginx.ingress.kubernetes.io/rewrite-target: /$2
        path: /admin(/|$)(.*)
        hostname: interop-switch.${private_subdomain}
    mysql:
      enabled: false
    kafka:
      enabled: false
  centralsettlement:
    centralsettlement-service:
      ingress:
        enabled: true
        className: *INGRESS_CLASS
        annotations:
          nginx.ingress.kubernetes.io/rewrite-target: /v2/$2
        path: /settlements(/|$)(.*)
        hostname: interop-switch.${private_subdomain}
      config:
        kafka_host: *KAFKA_HOST
        kafka_port: *KAFKA_PORT
        db_password: *CS_DB_PASSWORD
        db_host: *CS_DB_HOST
        db_user: *CS_DB_USER
        db_port: *CS_DB_PORT        
        db_database: *CS_DB_DATABASE
    centralsettlement-handler-deferredsettlement:
      config:
        kafka_host: *KAFKA_HOST
        kafka_port: *KAFKA_PORT
        db_password: *CS_DB_PASSWORD
        db_host: *CS_DB_HOST
        db_user: *CS_DB_USER
        db_port: *CS_DB_PORT        
        db_database: *CS_DB_DATABASE
    centralsettlement-handler-grosssettlement:
      config:
        kafka_host: *KAFKA_HOST
        kafka_port: *KAFKA_PORT
        db_password: *CS_DB_PASSWORD
        db_host: *CS_DB_HOST
        db_user: *CS_DB_USER
        db_port: *CS_DB_PORT        
        db_database: *CS_DB_DATABASE
    centralsettlement-handler-rules:
      config:
        kafka_host: *KAFKA_HOST
        kafka_port: *KAFKA_PORT
        db_password: *CS_DB_PASSWORD
        db_host: *CS_DB_HOST
        db_user: *CS_DB_USER
        db_port: *CS_DB_PORT        
        db_database: *CS_DB_DATABASE

emailnotifier:
  enabled: false
  config:
    kafka_host: *KAFKA_HOST
    kafka_port: *KAFKA_PORT
ml-api-adapter:
  ml-api-adapter-handler-notification:
    config:
      kafka_host: *KAFKA_HOST
      kafka_port: *KAFKA_PORT
      endpointSecurity:
        jwsSigningKey: |-
          ${indent(10, jws_signing_priv_key)}
    ingress:
      enabled: true
      className: *INGRESS_CLASS
      hostname: ml-api-adapter-handler-notification.${private_subdomain}
  ml-api-adapter-service:
    config:
      kafka_host: *KAFKA_HOST
      kafka_port: *KAFKA_PORT
    ingress:
      enabled: true
      className: *INGRESS_CLASS
      #annotations:
        #nginx.ingress.kubernetes.io/rewrite-target: /$2
      hostname: ml-api-adapter.${private_subdomain}
quoting-service:
  sidecar:
    enabled: true
  config:
    kafka_host: *KAFKA_HOST
    kafka_port: *KAFKA_PORT
    simple_routing_mode_enabled: ${quoting_service_simple_routing_mode_enabled}
    log_transport: "console"
    log_level: "debug"
    db_password: *QUOTING_DB_PASSWORD
    db_host: *QUOTING_DB_HOST
    db_user: *QUOTING_DB_USER
    db_port: *QUOTING_DB_PORT
    db_database: *QUOTING_DB_DATABASE
    endpointSecurity:
      jwsSigningKey: |-
        ${indent(8, jws_signing_priv_key)}
  ingress:
    enabled: true
    className: *INGRESS_CLASS
    hostname: quoting-service.${private_subdomain}

simulator:
  ingress:
    enabled: true
    className: *INGRESS_CLASS
    hostname: moja-simulator.${private_subdomain}

mojaloop-bulk:
  enabled: ${bulk_enabled}
  mongodb:
    enabled: false
  bulk-centralledger:
    cl-handler-bulk-transfer-get:
      config:
        kafka_host: *KAFKA_HOST
        kafka_port: *KAFKA_PORT
        db_password: *CL_DB_PASSWORD
        db_host: *CL_DB_HOST
        db_user: *CL_DB_USER
        db_port: *CL_DB_PORT        
        db_database: *CL_DB_DATABASE
        objstore_uri: *OBJSTORE_URI
    cl-handler-bulk-transfer-prepare:
      config:
        kafka_host: *KAFKA_HOST
        kafka_port: *KAFKA_PORT
        db_password: *CL_DB_PASSWORD
        db_host: *CL_DB_HOST
        db_user: *CL_DB_USER
        db_port: *CL_DB_PORT        
        db_database: *CL_DB_DATABASE
        objstore_uri: *OBJSTORE_URI
    cl-handler-bulk-transfer-fulfil:
      config:
        kafka_host: *KAFKA_HOST
        kafka_port: *KAFKA_PORT
        db_password: *CL_DB_PASSWORD
        db_host: *CL_DB_HOST
        db_user: *CL_DB_USER
        db_port: *CL_DB_PORT        
        db_database: *CL_DB_DATABASE
        objstore_uri: *OBJSTORE_URI
    cl-handler-bulk-transfer-processing:
      config:
        kafka_host: *KAFKA_HOST
        kafka_port: *KAFKA_PORT
        db_password: *CL_DB_PASSWORD
        db_host: *CL_DB_HOST
        db_user: *CL_DB_USER
        db_port: *CL_DB_PORT        
        db_database: *CL_DB_DATABASE
        objstore_uri: *OBJSTORE_URI
  bulk-api-adapter:
    bulk-api-adapter-handler-notification:
      config:
        kafka_host: *KAFKA_HOST
        kafka_port: *KAFKA_PORT
        objstore_uri: *OBJSTORE_URI
    bulk-api-adapter-service:
      config:
        kafka_host: *KAFKA_HOST
        kafka_port: *KAFKA_PORT
        objstore_uri: *OBJSTORE_URI
      ingress:
        enabled: true
        className: *INGRESS_CLASS
        hostname: bulk-api-adapter.${private_subdomain}

transaction-requests-service:
  ingress:
    enabled: true
    className: *INGRESS_CLASS
    hostname: transaction-request-service.${private_subdomain}

thirdparty:
  enabled: ${mojaloop_thirdparty_support_enabled}
  auth-svc:
    enabled: true
    config:
      production.json: {
        "PARTICIPANT_ID": "centralauth",
        "REDIS": {
          "PORT": ${third_party_auth_redis_port},
          "HOST": ${third_party_auth_redis_host},
        },
        "SHARED": {
          "JWS_SIGN": false,
          "JWS_SIGNING_KEY": "./secrets/jwsSigningKey.key"
        },
        "DATABASE": {
          "client": "mysql",
          "version": "5.5",
          "connection": {
            "host": "${third_party_auth_db_host}",
            "port": ${third_party_auth_db_port},
            "user": "${third_party_auth_db_user}",
            "password": "${third_party_auth_db_password}",
            "database": "${third_party_auth_db_database}",
            "timezone": "UTC"
          }
        },
        "DEMO_SKIP_VALIDATION_FOR_CREDENTIAL_IDS": [
          "HskU2gw4np09IUtYNHnxMM696jJHqvccUdBmd0xP6XEWwH0xLei1PUzDJCM19SZ3A2Ex0fNLw0nc2hrIlFnAtw"
        ]
      }
    ingress:
      enabled: true
      hostname: auth-service.upgtest.${private_subdomain}
      className: *INGRESS_CLASS

  consent-oracle:
    enabled: true
    config:
      default.json: {
        "DATABASE": {
          "HOST": "${third_party_consent_db_host}",
          "PORT": "${third_party_consent_db_port}",
          "USER": "${third_party_consent_db_user}",
          "PASSWORD": "${third_party_consent_db_password}",
          "DATABASE": "${third_party_consent_db_database}"
        }
      }

    ingress:
      enabled: true
      hostname: consent-oracle.upgtest.${private_subdomain}
      className: *INGRESS_CLASS

  tp-api-svc:
    enabled: true

    ingress:
      enabled: true
      hostname: tp-api-svc.upgtest.${private_subdomain}
      className: *INGRESS_CLASS

ml-ttk-test-val-bulk:
  tests:
    enabled: true

ml-ttk-test-setup-tp:
  tests:
    enabled: true

ml-ttk-test-val-tp:
  tests:
    enabled: true

mojaloop-ttk-simulators:
  enabled: ${ttksims_enabled}

  mojaloop-ttk-sim1-svc:
    enabled: true
    sdk-scheme-adapter: &MOJA_TTK_SIM_SDK
      sdk-scheme-adapter-api-svc:
        ingress:
          enabled: false
        kafka:
          host: *MOJA_TTK_SIM_KAFKA_HOST
          port: *MOJA_TTK_SIM_KAFKA_PORT

        redis:
          host: *MOJA_TTK_SIM_REDIS_HOST
          port: *MOJA_TTK_SIM_REDIS_PORT

      sdk-scheme-adapter-dom-evt-handler:
        kafka:
          host: *MOJA_TTK_SIM_KAFKA_HOST
          port: *MOJA_TTK_SIM_KAFKA_PORT

        redis:
          host: *MOJA_TTK_SIM_REDIS_HOST
          port: *MOJA_TTK_SIM_REDIS_PORT

      sdk-scheme-adapter-cmd-evt-handler:
        kafka:
          host: *MOJA_TTK_SIM_KAFKA_HOST
          port: *MOJA_TTK_SIM_KAFKA_PORT

        redis:
          host: *MOJA_TTK_SIM_REDIS_HOST
          port: *MOJA_TTK_SIM_REDIS_PORT

    ml-testing-toolkit:
      ml-testing-toolkit-backend:
        ingress:
          enabled: true
          hosts:
            specApi:
              host: ttksim1-specapi.${private_subdomain}
            adminApi:
              host: ttksim1.${private_subdomain}

        extraEnvironments:
          hub-k8s-default-environment.json: &ttksim1InputValues {
            "inputValues": {
              "TTKSIM1_CURRENCY": "${ttk_test_currency1}",
              "TTKSIM2_CURRENCY": "${ttk_test_currency1}",
              "TTKSIM3_CURRENCY": "${ttk_test_currency1}"
            }
          }
      ml-testing-toolkit-frontend:
        ingress:
          enabled: true
          hosts:
            ui:
              host: ttksim1.${private_subdomain}
        config:
          API_BASE_URL: http://ttksim1.${private_subdomain}

  mojaloop-ttk-sim2-svc:
    enabled: true
    sdk-scheme-adapter: *MOJA_TTK_SIM_SDK
    ml-testing-toolkit:
      ml-testing-toolkit-backend:
        ingress:
          enabled: true
          hosts:
            specApi:
              host: ttksim2-specapi.${private_subdomain}
            adminApi:
              host: ttksim2.${private_subdomain}

      ml-testing-toolkit-frontend:
        ingress:
          enabled: true
          hosts:
            ui:
              host: ttksim2.${private_subdomain}s
        config:
          API_BASE_URL: http://ttksim2.${private_subdomain}

  mojaloop-ttk-sim3-svc:
    enabled: true
    sdk-scheme-adapter: *MOJA_TTK_SIM_SDK
    ml-testing-toolkit:
      ml-testing-toolkit-backend:
        ingress:
          enabled: true
          hosts:
            specApi:
              host: ttksim3-specapi.${private_subdomain}
            adminApi:
              host: ttksim3.${private_subdomain}

      ml-testing-toolkit-frontend:
        ingress:
          enabled: true
          hosts:
            ui:
              host: ttksim3.${private_subdomain}
        config:
          API_BASE_URL: http://ttksim3.${private_subdomain}
