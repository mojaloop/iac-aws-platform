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
  objstore_uri: &OBJSTORE_URI 'mongodb://${cl_mongodb_user}:${cl_mongodb_pass}@${cl_mongodb_host}:${cl_mongodb_port}/${cl_mongodb_database}'
  ingress_class: &INGRESS_CLASS "${ingress_class_name}"

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
      hostname: account-lookup-service.${internal_subdomain}
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
      hostname: account-lookup-service-admin.${internal_subdomain}
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
      hostname: central-event-processor.${internal_subdomain}
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
        hostname: central-ledger-admin-transfer.${internal_subdomain}
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
        hostname: central-ledger-timeout.${internal_subdomain}
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
        hostname: central-ledger-transfer-fulfil.${internal_subdomain}
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
        hostname: central-ledger-transfer-get.${internal_subdomain}
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
        hostname: central-ledger-transfer-position.${internal_subdomain}
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
        hostname: central-ledger-transfer-prepare.${internal_subdomain}
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
        hostname: interop-switch.${internal_subdomain}
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
        hostname: interop-switch.${internal_subdomain}
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
      hostname: ml-api-adapter-handler-notification.${internal_subdomain}
  ml-api-adapter-service:
    config:
      kafka_host: *KAFKA_HOST
      kafka_port: *KAFKA_PORT
    ingress:
      enabled: true
      className: *INGRESS_CLASS
      #annotations:
        #nginx.ingress.kubernetes.io/rewrite-target: /$2
      hostname: ml-api-adapter.${internal_subdomain}
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
    hostname: quoting-service.${internal_subdomain}

simulator:
  ingress:
    enabled: true
    className: *INGRESS_CLASS
    hostname: moja-simulator.${internal_subdomain}

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
        hostname: bulk-api-adapter.${internal_subdomain}

transaction-requests-service:
  ingress:
    enabled: true
    className: *INGRESS_CLASS
    hostname: transaction-request-service.${internal_subdomain}

thirdparty:
  enabled: ${mojaloop_thirdparty_support_enabled}
  auth-svc:
    enabled: true
    config:
      production.json: {
        "PARTICIPANT_ID": "centralauth",
        "REDIS": {
          "PORT": 6379,
          "HOST": "auth-svc-redis-svc",
        },
        "SHARED": {
          "JWS_SIGN": false,
          "JWS_SIGNING_KEY": "./secrets/jwsSigningKey.key"
        },
        "DATABASE": {
          "client": "mysql",
          "version": "5.5",
          "connection": {
            "host": "mysql-auth-svc",
            "port": 3306,
            "user": "auth-svc",
            "password": "password",
            "database": "auth-svc",
            "timezone": "UTC"
          }
        },
        "DEMO_SKIP_VALIDATION_FOR_CREDENTIAL_IDS": [
          "HskU2gw4np09IUtYNHnxMM696jJHqvccUdBmd0xP6XEWwH0xLei1PUzDJCM19SZ3A2Ex0fNLw0nc2hrIlFnAtw"
        ]
      }
    ingress:
      enabled: true
      hostname: auth-service.upgtest.${internal_subdomain}
      className: *INGRESS_CLASS

  consent-oracle:
    enabled: true
    config:
      default.json: {
        "DATABASE": {
          "HOST": "mysql-consent-oracle",
          "PORT": 3306,
          "USER": "consent-oracle",
          "PASSWORD": "password",
          "DATABASE": "consent-oracle"
        }
      }

    ingress:
      enabled: true
      hostname: consent-oracle.upgtest.${internal_subdomain}
      className: *INGRESS_CLASS

  tp-api-svc:
    enabled: true

    ingress:
      enabled: true
      hostname: tp-api-svc.upgtest.${internal_subdomain}
      className: *INGRESS_CLASS