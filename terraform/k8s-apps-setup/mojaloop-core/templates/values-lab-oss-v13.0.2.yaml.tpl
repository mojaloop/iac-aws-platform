global:
  config:
    forensicloggingsidecar_disabled: true

account-lookup-service:
  account-lookup-service:
    containers:
      api:
        image:
          repository: mojaloop/account-lookup-service
          tag: v11.8.0
    config:
      db_password: "${account_lookup_db_password}"
      db_host: "${account_lookup_db_host}"
      db_user: "${account_lookup_db_user}"
      endpointSecurity:
        jwsSigningKey: |-
          ${indent(10, jws_signing_priv_key)}
    ingress:
      annotations:
        kubernetes.io/ingress.class: nginx
      hosts:
        - account-lookup-service.${private_subdomain}
  account-lookup-service-admin:
    containers:
      admin:
        image:
          repository: mojaloop/account-lookup-service
          tag: v11.8.0
    config:
      db_password: "${account_lookup_db_password}"
      db_host: "${account_lookup_db_host}"
      db_user: "${account_lookup_db_user}"
    ingress:
      annotations:
        kubernetes.io/ingress.class: nginx
      hosts:
        - account-lookup-service-admin.${private_subdomain}
  mysql:
    enabled: false
  als-oracle-pathfinder:
    enabled: false
central:
  centraleventprocessor:
    mongodb:
      enabled: false
    config:
      kafka_host: "${kafka_host}"
      mongo_host: ${cep_mongodb_host}
      mongo_user: ${cep_mongodb_user}
      mongo_password: ${cep_mongodb_pass}
      mongo_database: ${cep_mongodb_database}
    ingress:
      annotations:
        kubernetes.io/ingress.class: nginx
      hosts:
        api: central-event-processor.${private_subdomain}
  centralledger:
    centralledger-handler-admin-transfer:
      containers:
        api:
          image:
            repository: mojaloop/central-ledger
            tag: v13.14.3
      config:
        kafka_host: "${kafka_host}"
        db_password: "${central_ledger_db_password}"
        db_host: "${central_ledger_db_host}"
        resource_versions: 'transfers=1.1,participants=1.0,quotes=1.0'
      ingress:
        annotations:
          kubernetes.io/ingress.class: nginx
        hosts:
          api: central-ledger-admin-transfer.${private_subdomain}
    centralledger-handler-timeout:
      containers:
        api:
          image:
            repository: mojaloop/central-ledger
            tag: v13.14.3
      config:
        kafka_host: "${kafka_host}"
        db_password: "${central_ledger_db_password}"
        db_host: "${central_ledger_db_host}"
        db_user: "${central_ledger_db_user}"
        resource_versions: 'transfers=1.1,participants=1.0,quotes=1.0'
      ingress:
        annotations:
          kubernetes.io/ingress.class: nginx
        hosts:
          api: central-ledger-timeout.${private_subdomain}
    centralledger-handler-transfer-fulfil:
      containers:
        api:
          image:
            repository: mojaloop/central-ledger
            tag: v13.14.3
      config:
        kafka_host: "${kafka_host}"
        db_password: "${central_ledger_db_password}"
        db_host: "${central_ledger_db_host}"
        db_user: "${central_ledger_db_user}"
        resource_versions: 'transfers=1.1,participants=1.0,quotes=1.0'
      ingress:
        annotations:
          kubernetes.io/ingress.class: nginx
        hosts:
          api: central-ledger-transfer-fulfil.${private_subdomain}
    centralledger-handler-transfer-get:
      containers:
        api:
          image:
            repository: mojaloop/central-ledger
            tag: v13.14.3
      config:
        kafka_host: "${kafka_host}"
        db_password: "${central_ledger_db_password}"
        db_host: "${central_ledger_db_host}"
        db_user: "${central_ledger_db_user}"
        resource_versions: 'transfers=1.1,participants=1.0,quotes=1.0'
      ingress:
        annotations:
          kubernetes.io/ingress.class: nginx
        hosts:
          api: central-ledger-transfer-get.${private_subdomain}
    centralledger-handler-transfer-position:
      containers:
        api:
          image:
            repository: mojaloop/central-ledger
            tag: v13.14.3
      config:
        kafka_host: "${kafka_host}"
        db_password: "${central_ledger_db_password}"
        db_host: "${central_ledger_db_host}"
        db_user: "${central_ledger_db_user}"
        resource_versions: 'transfers=1.1,participants=1.0,quotes=1.0'
      ingress:
        annotations:
          kubernetes.io/ingress.class: nginx
        hosts:
          api: central-ledger-transfer-position.${private_subdomain}
    centralledger-handler-transfer-prepare:
      containers:
        api:
          image:
            repository: mojaloop/central-ledger
            tag: v13.14.3
      config:
        kafka_host: "${kafka_host}"
        db_password: "${central_ledger_db_password}"
        db_host: "${central_ledger_db_host}"
        db_user: "${central_ledger_db_user}"
        resource_versions: 'transfers=1.1,participants=1.0,quotes=1.0'
      ingress:
        annotations:
          kubernetes.io/ingress.class: nginx
        hosts:
          api: central-ledger-transfer-prepare.${private_subdomain}
    centralledger-service:
      containers:
        api:
          image:
            repository: mojaloop/central-ledger
            tag: v13.14.3
      config:
        kafka_host: "${kafka_host}"
        db_password: "${central_ledger_db_password}"
        db_host: "${central_ledger_db_host}"
        db_user: "${central_ledger_db_user}"
        resource_versions: 'transfers=1.1,participants=1.0,quotes=1.0'
      ingress:
        annotations:
          nginx.ingress.kubernetes.io/rewrite-target: /$2
          kubernetes.io/ingress.class: nginx
        externalPath:
            api: /admin(/|$)(.*)
        hosts:
          api: interop-switch.${private_subdomain}
          admin: interop-switch.${private_subdomain}
        mysql:
    mysql:
      enabled: false
    kafka:
      enabled: false
  centralsettlement:
    centralsettlement-service:
      ingress:
        annotations:
          nginx.ingress.kubernetes.io/rewrite-target: /v2/$2
          kubernetes.io/ingress.class: nginx
        externalPath: 
          api: /settlements(/|$)(.*)
        hosts:
          api: interop-switch.${private_subdomain}
      config:
        kafka_host: "${kafka_host}"
        db_password: "${central_settlement_db_password}"
        db_host: "${central_settlement_db_host}"
        db_user: "${central_settlement_db_user}"
    centralsettlement-handler-deferredsettlement:
      config:
        kafka_host: "${kafka_host}"
        db_password: "${central_settlement_db_password}"
        db_host: "${central_settlement_db_host}"
        db_user: "${central_settlement_db_user}"
    centralsettlement-handler-grosssettlement:
      config:
        kafka_host: "${kafka_host}"
        db_password: "${central_settlement_db_password}"
        db_host: "${central_settlement_db_host}"
        db_user: "${central_settlement_db_user}"
    centralsettlement-handler-rules:
      config:
        kafka_host: "${kafka_host}"
        db_password: "${central_settlement_db_password}"
        db_host: "${central_settlement_db_host}"
        db_user: "${central_settlement_db_user}"
    centralsettlement-handler-settlementwindow:
      config:
        kafka_host: "${kafka_host}"
        db_password: "${central_settlement_db_password}"
        db_host: "${central_settlement_db_host}"
        db_user: "${central_settlement_db_user}"
    centralsettlement-handler-transfersettlement:
      config:
        kafka_host: "${kafka_host}"
        db_password: "${central_settlement_db_password}"
        db_host: "${central_settlement_db_host}"
        db_user: "${central_settlement_db_user}"

emailnotifier:
  ingress:
    annotations:
      kubernetes.io/ingress.class: nginx
    hosts:
      api: emailnotifier.${private_subdomain}
ml-api-adapter:
  ml-api-adapter-handler-notification:
    config:
      kafka_host: "${kafka_host}"
      resource_versions: 'transfers=1.1,participants=1.0,quotes=1.0'
      endpointSecurity:
        jwsSigningKey: |-
          ${indent(10, jws_signing_priv_key)}
    image:
      repository: mojaloop/ml-api-adapter
      tag: v11.2.0
    ingress:
      annotations:
        kubernetes.io/ingress.class: nginx
      hosts:
        api: ml-api-adapter-handler-notification.${private_subdomain}
  ml-api-adapter-service:
    config:
      kafka_host: "${kafka_host}"
      resource_versions: 'transfers=1.1,participants=1.0,quotes=1.0'
    image:
      repository: mojaloop/ml-api-adapter
      tag: v11.2.0
    ingress:
      modernIngressController: true
      modernIngressControllerRegex: (/|$)(.*)
      annotations:
        nginx.ingress.kubernetes.io/rewrite-target: /$2
        kubernetes.io/ingress.class: nginx
      hosts:
        api: ml-api-adapter.${private_subdomain}
quoting-service:
  sidecar:
    enabled: true
  config:
    kafka_host: "${kafka_host}"
    simple_routing_mode_enabled: false
    log_transport: "console"
    log_level: "debug"
    db_password: "${quoting_db_password}"
    db_host: "${quoting_db_host}"
    db_user: "${quoting_db_user}"
    endpointSecurity:
      jwsSigningKey: |-
        ${indent(8, jws_signing_priv_key)}
  ingress:
    annotations:
      kubernetes.io/ingress.class: nginx
    hosts:
      api: quoting-service.${private_subdomain}

simulator:
  ingress:
    annotations:
      kubernetes.io/ingress.class: nginx
    hosts:
      - moja-simulator.${private_subdomain}

finance-portal:
  config:
    db_password: "${finance_portal_db_password}"
    db_host: "${finance_portal_db_host}"
    db_user: "${finance_portal_db_user}"
    centralSettlementsEndpoint: '$release_name-centralsettlement-service/v2'
    oauthServer: ${wso2is_host}
    oauthClientKey: ${portal_oauth_app_id}
    oauthClientSecret: ${portal_oauth_app_token}
    BypassAuth: false
    InsecureCookie: true
  backend:
    image:
      tag: v15.3.2
    init:
      enabled: false
    ingress:
      enabled: true
      externalPath: /admin-portal-backend(/|$)(.*)
      hosts:
        api: finance-portal.${private_subdomain}
      annotations:
        nginx.ingress.kubernetes.io/rewrite-target: /$2
        kubernetes.io/ingress.class: nginx
  frontend: 
    ingress:
      enabled: true
      hosts:
        api: finance-portal.${private_subdomain}
      annotations:
        nginx.ingress.kubernetes.io/rewrite-target: ""
        kubernetes.io/ingress.class: nginx
finance-portal-settlement-management:
  enabled: false
  config:
    db_password: "${finance_portal_db_password}"
    db_host: "${finance_portal_db_host}"
    db_user: "${finance_portal_db_user}"
mojaloop-bulk:
  enabled: true
  mongodb:
    enabled: false
  bulk-centralledger:
    cl-handler-bulk-transfer-get:
      config:
        kafka_host: "${kafka_host}"
        db_password: "${central_ledger_db_password}"
        db_host: "${central_ledger_db_host}"
        db_user: "${central_ledger_db_user}"
        objstore_uri: 'mongodb://${cl_mongodb_user}:${cl_mongodb_pass}@${cl_mongodb_host}:27017/${cl_mongodb_database}'
    cl-handler-bulk-transfer-prepare:
      config:
        kafka_host: "${kafka_host}"
        db_password: "${central_ledger_db_password}"
        db_host: "${central_ledger_db_host}"
        db_user: "${central_ledger_db_user}"
        objstore_uri: 'mongodb://${cl_mongodb_user}:${cl_mongodb_pass}@${cl_mongodb_host}:27017/${cl_mongodb_database}'
    cl-handler-bulk-transfer-fulfil:
      config:
        kafka_host: "${kafka_host}"
        db_password: "${central_ledger_db_password}"
        db_host: "${central_ledger_db_host}"
        db_user: "${central_ledger_db_user}"
        objstore_uri: 'mongodb://${cl_mongodb_user}:${cl_mongodb_pass}@${cl_mongodb_host}:27017/${cl_mongodb_database}'
    cl-handler-bulk-transfer-processing:
      config:
        kafka_host: "${kafka_host}"
        db_password: "${central_ledger_db_password}"
        db_host: "${central_ledger_db_host}"
        db_user: "${central_ledger_db_user}"
        objstore_uri: 'mongodb://${cl_mongodb_user}:${cl_mongodb_pass}@${cl_mongodb_host}:27017/${cl_mongodb_database}'
  bulk-api-adapter:
    bulk-api-adapter-handler-notification:
      config:
        kafka_host: "${kafka_host}"
        objstore_uri: 'mongodb://${cl_mongodb_user}:${cl_mongodb_pass}@${cl_mongodb_host}:27017/${cl_mongodb_database}'
    bulk-api-adapter-service:
      config:
        kafka_host: "${kafka_host}"
        objstore_uri: 'mongodb://${cl_mongodb_user}:${cl_mongodb_pass}@${cl_mongodb_host}:27017/${cl_mongodb_database}'
      ingress:
        annotations:
          kubernetes.io/ingress.class: nginx
        hosts:
          api: bulk-api-adapter.${private_subdomain}

transaction-requests-service:
  ingress:
    annotations:
      kubernetes.io/ingress.class: nginx
    hosts:
      api: transaction-request-service.${private_subdomain}
