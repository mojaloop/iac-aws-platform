# Custom YAML TEMPLATE Anchors
CONFIG:
  ## ACCOUNT-LOOKUP BACKEND
  als_db_database: &ALS_DB_DATABASE "${account_lookup_db_database}"
  als_db_password: &ALS_DB_PASSWORD "${account_lookup_db_password}"
  ## TODO: Enable the following secret file and remove the above plain text password
  # als_db_secret: &ALS_DB_SECRET
  #   name: &ALS_DB_SECRET_NAME mysqldb
  #   key: &ALS_DB_SECRET_KEY mysql-password
  als_db_host: &ALS_DB_HOST "${account_lookup_db_host}"
  als_db_port: &ALS_DB_PORT ${account_lookup_db_port}
  als_db_user: &ALS_DB_USER "${account_lookup_db_user}"

  ## CENTRAL-LEDGER BACKEND
  cl_db_database: &CL_DB_DATABASE "${central_ledger_db_database}"
  cl_db_password: &CL_DB_PASSWORD "${central_ledger_db_password}"
  ## TODO: Enable the following secret file and remove the above plain text password
  # cl_db_secret: &CL_DB_SECRET
  #   name: &CL_DB_SECRET_NAME mysqldb
  #   key: &CL_DB_SECRET_KEY mysql-password
  cl_db_host: &CL_DB_HOST "${central_ledger_db_host}"
  cl_db_port: &CL_DB_PORT ${central_ledger_db_port}
  cl_db_user: &CL_DB_USER "${central_ledger_db_user}"

  ## KAFKA BACKEND
  kafka_host: &KAFKA_HOST "${kafka_host}"
  kafka_port: &KAFKA_PORT ${kafka_port}

  ## BULK OBJECT STORE BACKEND
  obj_mongo_host: &OBJSTORE_MONGO_HOST "${cl_mongodb_host}"
  obj_mongo_port: &OBJSTORE_MONGO_PORT ${cl_mongodb_port}
  obj_mongo_user: &OBJSTORE_MONGO_USER "${cl_mongodb_user}"
  obj_mongo_password: &OBJSTORE_MONGO_PASSWORD "${cl_mongodb_pass}"
  ## TODO: Enable the following secret file and remove the above plain text password
  # obj_mongo_secret: &OBJSTORE_MONGO_SECRET
  #   name: &OBJSTORE_MONGO_SECRET_NAME cl-mongodb
  #   key: &OBJSTORE_MONGO_SECRET_KEY mongodb-passwords
  obj_mongo_database: &OBJSTORE_MONGO_DATABASE "${cl_mongodb_database}"

  ## MOJALOOP-TTK-SIMULATORS BACKEND
  moja_ttk_sim_kafka_host: &MOJA_TTK_SIM_KAFKA_HOST "${kafka_host}"
  moja_ttk_sim_kafka_port: &MOJA_TTK_SIM_KAFKA_PORT ${kafka_port}
  moja_ttk_sim_redis_host: &MOJA_TTK_SIM_REDIS_HOST "${ttksims_redis_host}"
  moja_ttk_sim_redis_port: &MOJA_TTK_SIM_REDIS_PORT ${ttksims_redis_port}

  ## THIRDPARTY AUTH-SVC BACKEND
  tp_auth_svc_db_database: &TP_AUTH_SVC_DB_DATABASE "${third_party_auth_db_database}"
  tp_auth_svc_db_password: &TP_AUTH_SVC_DB_PASSWORD "${third_party_auth_db_password}"
  ## TODO: Enable the following secret file and remove the above plain text password
  # tp_auth_svc_db_secret: &TP_AUTH_SVC_DB_SECRET
  #   name: &TP_AUTH_SVC_DB_SECRET_NAME mysqldb
  #   key: &TP_AUTH_SVC_DB_SECRET_KEY mysql-password
  tp_auth_svc_db_host: &TP_AUTH_SVC_DB_HOST "${third_party_auth_db_host}"
  tp_auth_svc_db_port: &TP_AUTH_SVC_DB_PORT ${third_party_auth_db_port}
  tp_auth_svc_db_user: &TP_AUTH_SVC_DB_USER "${third_party_auth_db_user}"
  tp_auth_svc_redis_host: &TP_AUTH_SVC_REDIS_HOST "${third_party_auth_redis_host}"
  tp_auth_svc_redis_port: &TP_AUTH_SVC_REDIS_PORT ${third_party_auth_redis_port}

  ## THIRDPARTY ALS_CONSENT-SVC BACKEND
  tp_als_consent_svc_db_database: &TP_ALS_CONSENT_SVC_DB_DATABASE "${third_party_consent_db_database}"
  tp_als_consent_svc_db_password: &TP_ALS_CONSENT_SVC_DB_PASSWORD "${third_party_consent_db_password}"
  ## TODO: Enable the following secret file and remove the above plain text password
  # tp_als_consent_svc_db_secret: &TP_ALS_CONSENT_SVC_DB_SECRET
  #   name: &TP_ALS_CONSENT_SVC_DB_SECRET_NAME mysqldb
  #   key: &TP_ALS_CONSENT_SVC_DB_SECRET_KEY mysql-password
  tp_als_consent_svc_db_host: &TP_ALS_CONSENT_SVC_DB_HOST "${third_party_consent_db_host}"
  tp_als_consent_svc_db_port: &TP_ALS_CONSENT_SVC_DB_PORT ${third_party_consent_db_port}
  tp_als_consent_svc_db_user: &TP_ALS_CONSENT_SVC_DB_USER "${third_party_consent_db_user}"


  ## CENTRAL-SETTLEMENT BACKEND
  cs_db_host: &CS_DB_HOST "${central_settlement_db_host}"
  cs_db_password: &CS_DB_PASSWORD "${central_settlement_db_password}"
  ## TODO: Enable the following secret file and remove the above plain text password
  # cs_db_secret: &CS_DB_SECRET
  #   name: &CS_DB_SECRET_NAME mysqldb
  #   key: &CS_DB_SECRET_KEY mysql-password
  cs_db_user: &CS_DB_USER "${central_settlement_db_user}"
  cs_db_port: &CS_DB_PORT ${central_settlement_db_port}
  cs_db_database: &CS_DB_DATABASE "${central_settlement_db_database}"

  ## QUOTING BACKEND
  quoting_db_host: &QUOTING_DB_HOST "${quoting_db_host}"
  quoting_db_password: &QUOTING_DB_PASSWORD "${quoting_db_password}"
  ## TODO: Enable the following secret file and remove the above plain text password
  # quoting_db_secret: &QUOTING_DB_SECRET
  #   name: &QUOTING_DB_SECRET_NAME mysqldb
  #   key: &QUOTING_DB_SECRET_KEY mysql-password
  quoting_db_user: &QUOTING_DB_USER "${quoting_db_user}"
  quoting_db_port: &QUOTING_DB_PORT ${quoting_db_port}
  quoting_db_database: &QUOTING_DB_DATABASE "${quoting_db_database}"

  ingress_class: &INGRESS_CLASS "${ingress_class_name}"

global:
  config:
    forensicloggingsidecar_disabled: true

account-lookup-service:
  account-lookup-service:
    config:
      db_password: *ALS_DB_PASSWORD
      db_secret: null
      ## TODO: Enable the following secret file and remove the above plain text password
      # db_secret: *ALS_DB_SECRET
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
      db_secret: null
      ## TODO: Enable the following secret file and remove the above plain text password
      # db_secret: *ALS_DB_SECRET
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
  als-oracle-pathfinder:
    enabled: false

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
    db_secret: null
    ## TODO: Enable the following secret file and remove the above plain text password
    # db_secret: *QUOTING_DB_SECRET
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

ml-api-adapter:
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

centralledger:
  centralledger-service:
    config:
      kafka_host: *KAFKA_HOST
      kafka_port: *KAFKA_PORT
      db_password: *CL_DB_PASSWORD
      db_secret: null
      ## TODO: Enable the following secret file and remove the above plain text password
      # db_secret: *CL_DB_SECRET
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
  centralledger-handler-transfer-prepare:
    config:
      kafka_host: *KAFKA_HOST
      kafka_port: *KAFKA_PORT
      db_password: *CL_DB_PASSWORD
      db_secret: null
      ## TODO: Enable the following secret file and remove the above plain text password
      # db_secret: *CL_DB_SECRET
      db_host: *CL_DB_HOST
      db_user: *CL_DB_USER
      db_port: *CL_DB_PORT        
      db_database: *CL_DB_DATABASE
    ingress:
      enabled: true
      className: *INGRESS_CLASS
      hostname: central-ledger-transfer-prepare.${private_subdomain}
  centralledger-handler-transfer-position:
    config:
      kafka_host: *KAFKA_HOST
      kafka_port: *KAFKA_PORT
      db_password: *CL_DB_PASSWORD
      db_secret: null
      ## TODO: Enable the following secret file and remove the above plain text password
      # db_secret: *CL_DB_SECRET
      db_host: *CL_DB_HOST
      db_user: *CL_DB_USER
      db_port: *CL_DB_PORT
      db_database: *CL_DB_DATABASE
    ingress:
      enabled: true
      className: *INGRESS_CLASS
      hostname: central-ledger-transfer-position.${private_subdomain}
  centralledger-handler-transfer-get:
    config:
      kafka_host: *KAFKA_HOST
      kafka_port: *KAFKA_PORT
      db_password: *CL_DB_PASSWORD
      db_secret: null
      ## TODO: Enable the following secret file and remove the above plain text password
      # db_secret: *CL_DB_SECRET
      db_host: *CL_DB_HOST
      db_user: *CL_DB_USER
      db_port: *CL_DB_PORT
      db_database: *CL_DB_DATABASE
    ingress:
      enabled: true
      className: *INGRESS_CLASS
      hostname: central-ledger-transfer-get.${private_subdomain}
  centralledger-handler-transfer-fulfil:
    config:
      kafka_host: *KAFKA_HOST
      kafka_port: *KAFKA_PORT
      db_password: *CL_DB_PASSWORD
      db_secret: null
      ## TODO: Enable the following secret file and remove the above plain text password
      # db_secret: *CL_DB_SECRET
      db_host: *CL_DB_HOST
      db_user: *CL_DB_USER
      db_port: *CL_DB_PORT
      db_database: *CL_DB_DATABASE
    ingress:
      enabled: true
      className: *INGRESS_CLASS
      hostname: central-ledger-transfer-fulfil.${private_subdomain}
  centralledger-handler-timeout:
    config:
      kafka_host: *KAFKA_HOST
      kafka_port: *KAFKA_PORT
      db_password: *CL_DB_PASSWORD
      db_secret: null
      ## TODO: Enable the following secret file and remove the above plain text password
      # db_secret: *CL_DB_SECRET
      db_host: *CL_DB_HOST
      db_user: *CL_DB_USER
      db_port: *CL_DB_PORT
      db_database: *CL_DB_DATABASE
    ingress:
      enabled: true
      className: *INGRESS_CLASS
      hostname: central-ledger-timeout.${private_subdomain}
  centralledger-handler-admin-transfer:
    config:
      kafka_host: *KAFKA_HOST
      kafka_port: *KAFKA_PORT
      db_password: *CL_DB_PASSWORD
      db_secret: null
      ## TODO: Enable the following secret file and remove the above plain text password
      # db_secret: *CL_DB_SECRET
      db_host: *CL_DB_HOST
      db_user: *CL_DB_USER    
      db_port: *CL_DB_PORT
      db_database: *CL_DB_DATABASE
    ingress:
      enabled: true
      className: *INGRESS_CLASS
      hostname: central-ledger-admin-transfer.${private_subdomain}

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
      db_secret: null
      ## TODO: Enable the following secret file and remove the above plain text password
      # db_secret: *CS_DB_SECRET
      db_host: *CS_DB_HOST
      db_user: *CS_DB_USER
      db_port: *CS_DB_PORT        
      db_database: *CS_DB_DATABASE
  centralsettlement-handler-deferredsettlement:
    config:
      kafka_host: *KAFKA_HOST
      kafka_port: *KAFKA_PORT
      db_password: *CS_DB_PASSWORD
      db_secret: null
      ## TODO: Enable the following secret file and remove the above plain text password
      # db_secret: *CS_DB_SECRET
      db_host: *CS_DB_HOST
      db_user: *CS_DB_USER
      db_port: *CS_DB_PORT        
      db_database: *CS_DB_DATABASE
  centralsettlement-handler-grosssettlement:
    config:
      kafka_host: *KAFKA_HOST
      kafka_port: *KAFKA_PORT
      db_password: *CS_DB_PASSWORD
      db_secret: null
      ## TODO: Enable the following secret file and remove the above plain text password
      # db_secret: *CS_DB_SECRET
      db_host: *CS_DB_HOST
      db_user: *CS_DB_USER
      db_port: *CS_DB_PORT        
      db_database: *CS_DB_DATABASE
  centralsettlement-handler-rules:
    config:
      kafka_host: *KAFKA_HOST
      kafka_port: *KAFKA_PORT
      db_password: *CS_DB_PASSWORD
      db_secret: null
      ## TODO: Enable the following secret file and remove the above plain text password
      # db_secret: *CS_DB_SECRET
      db_host: *CS_DB_HOST
      db_user: *CS_DB_USER
      db_port: *CS_DB_PORT        
      db_database: *CS_DB_DATABASE

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
      db_host: *TP_AUTH_SVC_DB_HOST
      db_port: *TP_AUTH_SVC_DB_PORT
      db_user: *TP_AUTH_SVC_DB_USER
      db_password: *TP_AUTH_SVC_DB_PASSWORD
      db_secret: null
      ## TODO: Enable the following secret file and remove the above plain text password
      # db_secret: * TP_AUTH_SVC_DB_SECRET
      db_database: *TP_AUTH_SVC_DB_DATABASE
      redis_host: *TP_AUTH_SVC_REDIS_HOST
      redis_port: *TP_AUTH_SVC_REDIS_PORT
    ingress:
      enabled: true
      hostname: auth-service.upgtest.${private_subdomain}
      className: *INGRESS_CLASS

  consent-oracle:
    enabled: true
    config:
      db_host: *TP_ALS_CONSENT_SVC_DB_HOST
      db_port: *TP_ALS_CONSENT_SVC_DB_PORT
      db_user: *TP_ALS_CONSENT_SVC_DB_USER
      db_password: *TP_ALS_CONSENT_SVC_DB_PASSWORD
      db_secret: null
      ## TODO: Enable the following secret file and remove the above plain text password
      # db_secret: * TP_ALS_CONSENT_SVC_DB_SECRET
      db_database: *TP_ALS_CONSENT_SVC_DB_DATABASE
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

  thirdparty-simulator:
    enabled: true

simulator:
  ingress:
    enabled: true
    className: *INGRESS_CLASS
    hostname: moja-simulator.${private_subdomain}

mojaloop-bulk:
  enabled: ${bulk_enabled}
  bulk-api-adapter:
    bulk-api-adapter-service:
      config:
        kafka_host: *KAFKA_HOST
        kafka_port: *KAFKA_PORT
        mongo_host: *OBJSTORE_MONGO_HOST
        mongo_port: *OBJSTORE_MONGO_PORT
        mongo_user: *OBJSTORE_MONGO_USER
        mongo_password: *OBJSTORE_MONGO_PASSWORD
        mongo_secret: null
        ## TODO: Enable the following secret file and remove the above plain text password
        # mongo_secret: *OBJSTORE_MONGO_SECRET
        mongo_database: *OBJSTORE_MONGO_DATABASE
      ingress:
        enabled: true
        className: *INGRESS_CLASS
        hostname: bulk-api-adapter.${private_subdomain}
    bulk-api-adapter-handler-notification:
      config:
        kafka_host: *KAFKA_HOST
        kafka_port: *KAFKA_PORT
        mongo_host: *OBJSTORE_MONGO_HOST
        mongo_port: *OBJSTORE_MONGO_PORT
        mongo_user: *OBJSTORE_MONGO_USER
        mongo_password: *OBJSTORE_MONGO_PASSWORD
        mongo_secret: null
        ## TODO: Enable the following secret file and remove the above plain text password
        # mongo_secret: *OBJSTORE_MONGO_SECRET
        mongo_database: *OBJSTORE_MONGO_DATABASE
  bulk-centralledger:
    cl-handler-bulk-transfer-prepare:
      config:
        kafka_host: *KAFKA_HOST
        kafka_port: *KAFKA_PORT
        db_password: *CL_DB_PASSWORD
        db_secret: null
        ## TODO: Enable the following secret file and remove the above plain text password
        # db_secret: *CL_DB_SECRET
        db_host: *CL_DB_HOST
        db_user: *CL_DB_USER
        db_port: *CL_DB_PORT        
        db_database: *CL_DB_DATABASE
        mongo_host: *OBJSTORE_MONGO_HOST
        mongo_port: *OBJSTORE_MONGO_PORT
        mongo_user: *OBJSTORE_MONGO_USER
        mongo_password: *OBJSTORE_MONGO_PASSWORD
        mongo_secret: null
        ## TODO: Enable the following secret file and remove the above plain text password
        # mongo_secret: *OBJSTORE_MONGO_SECRET
        mongo_database: *OBJSTORE_MONGO_DATABASE
    cl-handler-bulk-transfer-fulfil:
      config:
        kafka_host: *KAFKA_HOST
        kafka_port: *KAFKA_PORT
        db_password: *CL_DB_PASSWORD
        db_secret: null
        ## TODO: Enable the following secret file and remove the above plain text password
        # db_secret: *CL_DB_SECRET
        db_host: *CL_DB_HOST
        db_user: *CL_DB_USER
        db_port: *CL_DB_PORT        
        db_database: *CL_DB_DATABASE
        mongo_host: *OBJSTORE_MONGO_HOST
        mongo_port: *OBJSTORE_MONGO_PORT
        mongo_user: *OBJSTORE_MONGO_USER
        mongo_password: *OBJSTORE_MONGO_PASSWORD
        mongo_secret: null
        ## TODO: Enable the following secret file and remove the above plain text password
        # mongo_secret: *OBJSTORE_MONGO_SECRET
        mongo_database: *OBJSTORE_MONGO_DATABASE
    cl-handler-bulk-transfer-processing:
      config:
        kafka_host: *KAFKA_HOST
        kafka_port: *KAFKA_PORT
        db_password: *CL_DB_PASSWORD
        db_secret: null
        ## TODO: Enable the following secret file and remove the above plain text password
        # db_secret: *CL_DB_SECRET
        db_host: *CL_DB_HOST
        db_user: *CL_DB_USER
        db_port: *CL_DB_PORT        
        db_database: *CL_DB_DATABASE
        mongo_host: *OBJSTORE_MONGO_HOST
        mongo_port: *OBJSTORE_MONGO_PORT
        mongo_user: *OBJSTORE_MONGO_USER
        mongo_password: *OBJSTORE_MONGO_PASSWORD
        mongo_secret: null
        ## TODO: Enable the following secret file and remove the above plain text password
        # mongo_secret: *OBJSTORE_MONGO_SECRET
        mongo_database: *OBJSTORE_MONGO_DATABASE
    cl-handler-bulk-transfer-get:
      config:
        kafka_host: *KAFKA_HOST
        kafka_port: *KAFKA_PORT
        db_password: *CL_DB_PASSWORD
        db_secret: null
        ## TODO: Enable the following secret file and remove the above plain text password
        # db_secret: *CL_DB_SECRET
        db_host: *CL_DB_HOST
        db_user: *CL_DB_USER
        db_port: *CL_DB_PORT        
        db_database: *CL_DB_DATABASE
        mongo_host: *OBJSTORE_MONGO_HOST
        mongo_port: *OBJSTORE_MONGO_PORT
        mongo_user: *OBJSTORE_MONGO_USER
        mongo_password: *OBJSTORE_MONGO_PASSWORD
        mongo_secret: null
        ## TODO: Enable the following secret file and remove the above plain text password
        # mongo_secret: *OBJSTORE_MONGO_SECRET
        mongo_database: *OBJSTORE_MONGO_DATABASE

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
