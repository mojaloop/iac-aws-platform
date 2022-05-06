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
      annotations:
        kubernetes.io/ingress.class: nginx
      hosts:
        - account-lookup-service.${private_subdomain}
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
      annotations:
        kubernetes.io/ingress.class: nginx
      hosts:
        - account-lookup-service-admin.${private_subdomain}
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
      annotations:
        kubernetes.io/ingress.class: nginx
      hosts:
        api: central-event-processor.${private_subdomain}
  centralledger:
    centralledger-handler-admin-transfer:
      config:
        db_password: "${mysql_password}"
        resource_versions: 'transfers=1.1,participants=1.0,quotes=1.0'
      ingress:
        annotations:
          kubernetes.io/ingress.class: nginx
        hosts:
          api: central-ledger-admin-transfer.${private_subdomain}
    centralledger-handler-timeout:
      config:
        db_password: "${mysql_password}"
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
        db_password: "${mysql_password}"
        resource_versions: 'transfers=1.1,participants=1.0,quotes=1.0'
      ingress:
        annotations:
          kubernetes.io/ingress.class: nginx
        hosts:
          api: central-ledger-transfer-fulfil.${private_subdomain}
    centralledger-handler-transfer-get:
      config:
        db_password: "${mysql_password}"
        resource_versions: 'transfers=1.1,participants=1.0,quotes=1.0'
      ingress:
        annotations:
          kubernetes.io/ingress.class: nginx
        hosts:
          api: central-ledger-transfer-get.${private_subdomain}
    centralledger-handler-transfer-position:
      config:
        db_password: "${mysql_password}"
        resource_versions: 'transfers=1.1,participants=1.0,quotes=1.0'
      ingress:
        annotations:
          kubernetes.io/ingress.class: nginx
        hosts:
          api: central-ledger-transfer-position.${private_subdomain}
    centralledger-handler-transfer-prepare:
      config:
        db_password: "${mysql_password}"
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
        db_password: "${mysql_password}"
        resource_versions: 'transfers=1.1,participants=1.0,quotes=1.0'
      ingress:
        annotations:
          kubernetes.io/ingress.class: nginx
          nginx.ingress.kubernetes.io/rewrite-target: /$2
        externalPath:
            api: /admin(/|$)(.*)
        hosts:
          api: interop-switch.${private_subdomain}
          admin: interop-switch.${private_subdomain}
        mysql:
    mysql:
      mysqlPassword: "${mysql_password}"
      mysqlRootPassword: ${mysql_root_password}
      persistence:
        enabled: true
        accessMode: ReadWriteOnce
        size: 8Gi
        storageClass: ${storage_class_name}
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
        storageClass: ${storage_class_name}
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
        db_password: "${mysql_password}"
    centralsettlement-handler-settlementwindow:
      config:
        db_password: "${mysql_password}"
    centralsettlement-handler-transfersettlement:
      config:
        db_password: "${mysql_password}"
    
emailnotifier:
  ingress:
    annotations:
      kubernetes.io/ingress.class: nginx
    hosts:
      api: emailnotifier.${private_subdomain}   
ml-api-adapter:
  ml-api-adapter-handler-notification:
    config:
      resource_versions: 'transfers=1.1,participants=1.0,quotes=1.0'
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
  image:
    repository: mojaloop/quoting-service
    tag: v12.0.7
  sidecar:
    enabled: true
  config:
    simple_routing_mode_enabled: false
    log_transport: "console"
    log_level: "debug"
    db_password: "${mysql_password}"
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
