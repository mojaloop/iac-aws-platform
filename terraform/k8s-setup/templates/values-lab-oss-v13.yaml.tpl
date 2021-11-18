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
          tag: v11.8.0
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
          tag: v11.8.0
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
      containers:
        api:
          image:
            repository: mojaloop/central-ledger
            tag: v13.14.3
      config:
        db_password: "${mysql_password}"
        resource_versions: 'transfers=1.1,participants=1.0,quotes=1.0'
      ingress:
        hosts:
          api: central-ledger-admin-transfer.${env}.${name}.${domain}.internal
    centralledger-handler-timeout:
      containers:
        api:
          image:
            repository: mojaloop/central-ledger
            tag: v13.14.3
      config:
        db_password: "${mysql_password}"
        resource_versions: 'transfers=1.1,participants=1.0,quotes=1.0'
      ingress:
        hosts:
          api: central-ledger-timeout.${env}.${name}.${domain}.internal
    centralledger-handler-transfer-fulfil:
      containers:
        api:
          image:
            repository: mojaloop/central-ledger
            tag: v13.14.3
      config:
        db_password: "${mysql_password}"
        resource_versions: 'transfers=1.1,participants=1.0,quotes=1.0'
      ingress:
        hosts:
          api: central-ledger-transfer-fulfil.${env}.${name}.${domain}.internal
    centralledger-handler-transfer-get:
      containers:
        api:
          image:
            repository: mojaloop/central-ledger
            tag: v13.14.3
      config:
        db_password: "${mysql_password}"
        resource_versions: 'transfers=1.1,participants=1.0,quotes=1.0'
      ingress:
        hosts:
          api: central-ledger-transfer-get.${env}.${name}.${domain}.internal
    centralledger-handler-transfer-position:
      containers:
        api:
          image:
            repository: mojaloop/central-ledger
            tag: v13.14.3
      config:
        db_password: "${mysql_password}"
        resource_versions: 'transfers=1.1,participants=1.0,quotes=1.0'
      ingress:
        hosts:
          api: central-ledger-transfer-position.${env}.${name}.${domain}.internal
    centralledger-handler-transfer-prepare:
      containers:
        api:
          image:
            repository: mojaloop/central-ledger
            tag: v13.14.3
      config:
        db_password: "${mysql_password}"
        resource_versions: 'transfers=1.1,participants=1.0,quotes=1.0'
      ingress:
        hosts:
          api: central-ledger-transfer-prepare.${env}.${name}.${domain}.internal
    centralledger-service:
      containers:
        api:
          image:
            repository: mojaloop/central-ledger
            tag: v13.14.3
      config:
        db_password: "${mysql_password}"
        resource_versions: 'transfers=1.1,participants=1.0,quotes=1.0'
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
    centralsettlement-handler-deferredsettlement:
      config:
        db_password: "${mysql_password}"
    centralsettlement-handler-grosssettlement:
      config:
        db_password: "${mysql_password}"
    centralsettlement-handler-rules:
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
    config:
      resource_versions: 'transfers=1.1,participants=1.0,quotes=1.0'
    image:
      repository: mojaloop/ml-api-adapter
      tag: v11.2.0
    ingress:
      hosts:
        api: ml-api-adapter-handler-notification.${env}.${name}.${domain}.internal
  ml-api-adapter-service:
    config:
      resource_versions: 'transfers=1.1,participants=1.0,quotes=1.0'
    image:
      repository: mojaloop/ml-api-adapter
      tag: v11.2.0
    ingress:
      modernIngressController: true
      modernIngressControllerRegex: (/|$)(.*)
      annotations:
        nginx.ingress.kubernetes.io/rewrite-target: /$2
      hosts:
        api: ml-api-adapter.${env}.${name}.${domain}.internal
quoting-service:
  sidecar:
    enabled: true
  config:
    simple_routing_mode_enabled: false
    log_transport: "console"
    log_level: "debug"
    db_password: "${mysql_password}"
  ingress:
    hosts:
      api: quoting-service.${env}.${name}.${domain}.internal

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
      tag: v15.3.2
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

transaction-requests-service:
  ingress:
    hosts:
      api: transaction-request-service.${env}.${name}.${domain}.internal
