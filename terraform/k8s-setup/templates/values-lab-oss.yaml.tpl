global:
  config:
    db_password: KWvT8pzuBQ63Qp
    forensicloggingsidecar_disabled: true

account-lookup-service:
  account-lookup-service:
    config:
      db_password: KWvT8pzuBQ63Qp
    ingress:
      hosts:
        - account-lookup-service.${env}.${name}.${domain}.internal
    mysql:
      enabled: true
      mysqlPassword: KWvT8pzuBQ63Qp
      mysqlRootPassword: rUxHfAd7en
  account-lookup-service-admin:
    config:
      db_password: KWvT8pzuBQ63Qp
    ingress:
      hosts:
        - account-lookup-service-admin.${env}.${name}.${domain}.internal
  mysql:
    mysqlPassword: KWvT8pzuBQ63Qp
central:
  centraleventprocessor:
    ingress:
      hosts:
        api: central-event-processor.${env}.${name}.${domain}.internal
  centralledger:
    centralledger-handler-admin-transfer:
      config:
        db_password: KWvT8pzuBQ63Qp
      ingress:
        hosts:
          api: central-ledger-admin-transfer.${env}.${name}.${domain}.internal
    centralledger-handler-timeout:
      config:
        db_password: KWvT8pzuBQ63Qp
      ingress:
        hosts:
          api: central-ledger-timeout.${env}.${name}.${domain}.internal
    centralledger-handler-transfer-fulfil:
      config:
        db_password: KWvT8pzuBQ63Qp
      ingress:
        hosts:
          api: central-ledger-transfer-fulfil.${env}.${name}.${domain}.internal
    centralledger-handler-transfer-get:
      config:
        db_password: KWvT8pzuBQ63Qp
      ingress:
        hosts:
          api: central-ledger-transfer-get.${env}.${name}.${domain}.internal
    centralledger-handler-transfer-position:
      config:
        db_password: KWvT8pzuBQ63Qp
      ingress:
        hosts:
          api: central-ledger-transfer-position.${env}.${name}.${domain}.internal
    centralledger-handler-transfer-prepare:
      config:
        db_password: KWvT8pzuBQ63Qp
      ingress:
        hosts:
          api: central-ledger-transfer-prepare.${env}.${name}.${domain}.internal
    centralledger-service:
      config:
        db_password: KWvT8pzuBQ63Qp
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
      mysqlPassword: KWvT8pzuBQ63Qp
      mysqlRootPassword: rUxHfAd7en
      persistence:
        enabled: true
        accessMode: ReadWriteOnce
        size: 8Gi
        storageClass: slow
    kafka:
      configurationOverrides:
        log.retention.hours: ${kafka.retention_hours}
      persistence:
        enabled: true
        size: ${kafka.storage_size}
        mountPath: ${kafka.mountPath}
        storageClass: ${kafka.storage_type}
  centralsettlement:
    config:
      db_password: KWvT8pzuBQ63Qp
    ingress:
      annotations:
        nginx.ingress.kubernetes.io/rewrite-target: /v1/$2
      externalPath: /settlements(/|$)(.*)
      hosts:
        api: interop-switch.${env}.${name}.${domain}.internal
        admin: interop-switch.${env}.${name}.${domain}.internal
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
  sidecar:
    enabled: false
  image:
    tag: v11.0.2-snapshot
  config:
    simple_routing_mode_enabled: false
    log_transport: "console"
    log_level: "debug"
    db_password: KWvT8pzuBQ63Qp
  ingress:
    hosts:
      api: quoting-service.${env}.${name}.${domain}.internal
  rules: [{"conditions": {"all": [{"fact": "payer", "path": "$.accounts", "operator": "isArray", "value": false } ] }, "event": {"type": "INVALID_QUOTE_REQUEST", "params": {"FSPIOPError": "PAYER_ERROR", "message": "Payer does not have any active account"} } }, {"conditions": {"all": [{"fact": "payee", "path": "$.accounts", "operator": "isArray", "value": false } ] }, "event": {"type": "INVALID_QUOTE_REQUEST", "params": {"FSPIOPError": "PAYEE_ERROR", "message": "Payee does not have any active accounts"} } }, {"title": "This is USD -> AUD", "conditions": {"all": [{"fact": "headers", "path": "$.fspiop-source", "operator": "notIn", "value": ["DFSPUSD", "DFSPEUR", "DFSPAUD"] }, {"fact": "payer", "path": "$.accounts[?(@.ledgerAccountType == 'POSITION' && @.isActive  == 1)].currency", "operator": "equal", "value": "USD"}, {"fact": "payee", "path": "$.accounts[?(@.ledgerAccountType == 'POSITION' && @.isActive  == 1)].currency", "operator": "equal", "value": "AUD"} ] }, "event": {"type": "INTERCEPT_QUOTE", "params": {"rerouteToFsp": "DFSPUSD", "sourceCurrency": "USD", "rerouteToFspCurrency": "AUD"} } }, {"title": "This is AUD -> USD", "conditions": {"all": [{"fact": "headers", "path": "$.fspiop-source", "operator": "notIn", "value": ["DFSPUSD", "DFSPEUR", "DFSPAUD"] }, {"fact": "payer", "path": "$.accounts[?(@.ledgerAccountType == 'POSITION' && @.isActive  == 1)].currency", "operator": "equal", "value": "AUD"}, {"fact": "payee", "path": "$.accounts[?(@.ledgerAccountType == 'POSITION' && @.isActive  == 1)].currency", "operator": "equal", "value": "USD"} ] }, "event": {"type": "INTERCEPT_QUOTE", "params": {"rerouteToFsp": "DFSPAUD", "sourceCurrency": "AUD", "rerouteToFspCurrency": "USD"} } }, {"title": "This is EUR -> AUD", "conditions": {"all": [{"fact": "headers", "path": "$.fspiop-source", "operator": "notIn", "value": ["DFSPUSD", "DFSPEUR", "DFSPAUD"] }, {"fact": "payer", "path": "$.accounts[?(@.ledgerAccountType == 'POSITION' && @.isActive  == 1)].currency", "operator": "equal", "value": "EUR"}, {"fact": "payee", "path": "$.accounts[?(@.ledgerAccountType == 'POSITION' && @.isActive  == 1)].currency", "operator": "equal", "value": "AUD"} ] }, "event": {"type": "INTERCEPT_QUOTE", "params": {"rerouteToFsp": "DFSPEUR", "sourceCurrency": "EUR", "rerouteToFspCurrency": "AUD"} } }, {"title": "This is AUD -> EUR", "conditions": {"all": [{"fact": "headers", "path": "$.fspiop-source", "operator": "notIn", "value": ["DFSPUSD", "DFSPEUR", "DFSPAUD"] }, {"fact": "payer", "path": "$.accounts[?(@.ledgerAccountType == 'POSITION' && @.isActive  == 1)].currency", "operator": "equal", "value": "AUD"}, {"fact": "payee", "path": "$.accounts[?(@.ledgerAccountType == 'POSITION' && @.isActive  == 1)].currency", "operator": "equal", "value": "EUR"} ] }, "event": {"type": "INTERCEPT_QUOTE", "params": {"rerouteToFsp": "DFSPAUD", "sourceCurrency": "AUD", "rerouteToFspCurrency": "EUR"} } }, {"title": "This is EUR -> USD", "conditions": {"all": [{"fact": "headers", "path": "$.fspiop-source", "operator": "notIn", "value": ["DFSPUSD", "DFSPEUR", "DFSPAUD"] }, {"fact": "payer", "path": "$.accounts[?(@.ledgerAccountType == 'POSITION' && @.isActive  == 1)].currency", "operator": "equal", "value": "EUR"}, {"fact": "payee", "path": "$.accounts[?(@.ledgerAccountType == 'POSITION' && @.isActive  == 1)].currency", "operator": "equal", "value": "USD"} ] }, "event": {"type": "INTERCEPT_QUOTE", "params": {"rerouteToFsp": "DFSPEUR", "sourceCurrency": "EUR", "rerouteToFspCurrency": "USD"} } }, {"title": "This is USD -> EUR", "conditions": {"all": [{"fact": "headers", "path": "$.fspiop-source", "operator": "notIn", "value": ["DFSPUSD", "DFSPEUR", "DFSPAUD"] }, {"fact": "payer", "path": "$.accounts[?(@.ledgerAccountType == 'POSITION' && @.isActive  == 1)].currency", "operator": "equal", "value": "USD"}, {"fact": "payee", "path": "$.accounts[?(@.ledgerAccountType == 'POSITION' && @.isActive  == 1)].currency", "operator": "equal", "value": "EUR"} ] }, "event": {"type": "INTERCEPT_QUOTE", "params": {"rerouteToFsp": "DFSPUSD", "sourceCurrency": "USD", "rerouteToFspCurrency": "EUR"} } }, {"conditions": {"all": [{"fact": "payload", "path": "$.amountType", "operator": "equal", "value": "SEND"}, {"fact": "payload", "path": "$.amount.currency", "operator": "notIn", "value": {"fact": "payer", "path": "$.accounts[?(@.ledgerAccountType == 'POSITION' && @.isActive  == 1)].currency"} } ] }, "event": {"type": "INVALID_QUOTE_REQUEST", "params": {"FSPIOPError": "PAYER_UNSUPPORTED_CURRENCY", "message": "Requested currency not available for payer"} } }, {"conditions": {"all": [{"fact": "payload", "path": "$.amountType", "operator": "equal", "value": "RECEIVE"}, {"fact": "payload", "path": "$.amount.currency", "operator": "notIn", "value": {"fact": "payee", "path": "$.accounts[?(@.ledgerAccountType == 'POSITION' && @.isActive  == 1)].currency"} } ] }, "event": {"type": "INVALID_QUOTE_REQUEST", "params": {"FSPIOPError": "PAYEE_UNSUPPORTED_CURRENCY", "message": "Requested currency not available for payee"} } }, {"conditions": {"all": [{"any": [{"fact": "payload", "path": "$.amount.currency", "operator": "notIn", "value": {"fact": "payee", "path": "$.accounts[?(@.ledgerAccountType == 'POSITION' && @.isActive  == 1)].currency"} }, {"fact": "payload", "path": "$.amount.currency", "operator": "notIn", "value": {"fact": "payer", "path": "$.accounts[?(@.ledgerAccountType == 'POSITION' && @.isActive  == 1)].currency"} } ] }, {"fact": "headers", "path": "$.fspiop-source", "operator": "notIn", "value": ["DFSPEUR", "DFSPUSD", "DFSPAUD"] }, {"fact": "headers", "path": "$.fspiop-source", "operator": "notEqual", "value": {"fact": "payload", "path": "$.payer.partyIdInfo.fspId"} } ] }, "event": {"type": "INVALID_QUOTE_REQUEST", "params": {"FSPIOPError": "VALIDATION_ERROR", "message": "The payer FSP does not match the fspiop-source header"} } }, {"conditions": {"all": [{"any": [{"fact": "payload", "path": "$.amount.currency", "operator": "notIn", "value": {"fact": "payee", "path": "$.accounts[?(@.ledgerAccountType == 'POSITION' && @.isActive  == 1)].currency"} }, {"fact": "payload", "path": "$.amount.currency", "operator": "notIn", "value": {"fact": "payer", "path": "$.accounts[?(@.ledgerAccountType == 'POSITION' && @.isActive  == 1)].currency"} } ] }, {"fact": "payload", "path": "$.payer.personalInfo", "operator": "isObject", "value": false } ] }, "event": {"type": "INVALID_QUOTE_REQUEST", "params": {"FSPIOPError": "MISSING_ELEMENT", "message": "PartyPersonalInfo is required"} } }, {"conditions": {"all": [{"any": [{"fact": "payload", "path": "$.amount.currency", "operator": "notIn", "value": {"fact": "payee", "path": "$.accounts[?(@.ledgerAccountType == 'POSITION' && @.isActive  == 1)].currency"} }, {"fact": "payload", "path": "$.amount.currency", "operator": "notIn", "value": {"fact": "payer", "path": "$.accounts[?(@.ledgerAccountType == 'POSITION' && @.isActive  == 1)].currency"} } ] }, {"fact": "payload", "path": "$.payer.personalInfo.complexName.firstName", "operator": "isString", "value": false } ] }, "event": {"type": "INVALID_QUOTE_REQUEST", "params": {"FSPIOPError": "MISSING_ELEMENT", "message": "firstName is required"} } }, {"conditions": {"all": [{"any": [{"fact": "payload", "path": "$.amount.currency", "operator": "notIn", "value": {"fact": "payee", "path": "$.accounts[?(@.ledgerAccountType == 'POSITION' && @.isActive  == 1)].currency"} }, {"fact": "payload", "path": "$.amount.currency", "operator": "notIn", "value": {"fact": "payer", "path": "$.accounts[?(@.ledgerAccountType == 'POSITION' && @.isActive  == 1)].currency"} } ] }, {"fact": "payload", "path": "$.payer.personalInfo.complexName.lastName", "operator": "isString", "value": false } ] }, "event": {"type": "INVALID_QUOTE_REQUEST", "params": {"FSPIOPError": "MISSING_ELEMENT", "message": "lastName is required"} } }, {"conditions": {"all": [{"any": [{"fact": "payload", "path": "$.amount.currency", "operator": "notIn", "value": {"fact": "payee", "path": "$.accounts[?(@.ledgerAccountType == 'POSITION' && @.isActive  == 1)].currency"} }, {"fact": "payload", "path": "$.amount.currency", "operator": "notIn", "value": {"fact": "payer", "path": "$.accounts[?(@.ledgerAccountType == 'POSITION' && @.isActive  == 1)].currency"} } ] }, {"fact": "payload", "path": "$.payer.personalInfo.dateOfBirth", "operator": "isString", "value": false } ] }, "event": {"type": "INVALID_QUOTE_REQUEST", "params": {"FSPIOPError": "MISSING_ELEMENT", "message": "dateOfBirth is required"} } }, {"conditions": {"all": [{"any": [{"fact": "payload", "path": "$.amount.currency", "operator": "notIn", "value": {"fact": "payee", "path": "$.accounts[?(@.ledgerAccountType == 'POSITION' && @.isActive  == 1)].currency"} }, {"fact": "payload", "path": "$.amount.currency", "operator": "notIn", "value": {"fact": "payer", "path": "$.accounts[?(@.ledgerAccountType == 'POSITION' && @.isActive  == 1)].currency"} } ] }, {"fact": "payload", "path": "$.payer.personalInfo.dateOfBirth", "operator": "equal", "value": ""} ] }, "event": {"type": "INVALID_QUOTE_REQUEST", "params": {"FSPIOPError": "MALFORMED_SYNTAX", "message": "Malformed Payer dateOfBirth"} } }, {"conditions": {"all": [{"any": [{"fact": "payload", "path": "$.amount.currency", "operator": "notIn", "value": {"fact": "payer", "path": "$.accounts[?(@.ledgerAccountType == 'POSITION' && @.isActive  == 1)].currency"} }, {"fact": "payload", "path": "$.amount.currency", "operator": "notIn", "value": {"fact": "payee", "path": "$.accounts[?(@.ledgerAccountType == 'POSITION' && @.isActive  == 1)].currency"} } ] }, {"fact": "payer", "path": "$.accounts[?(@.ledgerAccountType == 'POSITION' && @.isActive  == 1)]", "operator": "isArray", "value": true } ] }, "event": {"type": "INVALID_QUOTE_REQUEST", "params": {"FSPIOPError": "PAYER_ERROR", "message": "Payer should not have more than 1 active currency account"} } }, {"conditions": {"all": [{"any": [{"fact": "payload", "path": "$.amount.currency", "operator": "notIn", "value": {"fact": "payee", "path": "$.accounts[?(@.ledgerAccountType == 'POSITION' && @.isActive  == 1)].currency"} }, {"fact": "payload", "path": "$.amount.currency", "operator": "notIn", "value": {"fact": "payer", "path": "$.accounts[?(@.ledgerAccountType == 'POSITION' && @.isActive  == 1)].currency"} } ] }, {"fact": "payee", "path": "$.accounts[?(@.ledgerAccountType == 'POSITION' && @.isActive  == 1)]", "operator": "isArray", "value": true } ] }, "event": {"type": "INVALID_QUOTE_REQUEST", "params": {"FSPIOPError": "PAYEE_ERROR", "message": "Payee should not have more than 1 active currency account"} } } ]

simulator:
  ingress:
    hosts:
      - moja-simulator.${env}.${name}.${domain}.internal
finance-portal:
  config:
    db_password: KWvT8pzuBQ63Qp
  backend: 
    ingress:
      enabled: true
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

mojaloop-bulk:
  enabled: true  
  bulk-centralledger:
    cl-handler-bulk-transfer-prepare:
      config:
        db_password: KWvT8pzuBQ63Qp
    cl-handler-bulk-transfer-fulfil:
      config:
        db_password: KWvT8pzuBQ63Qp
    cl-handler-bulk-transfer-processing:
      config:
        db_password: KWvT8pzuBQ63Qp