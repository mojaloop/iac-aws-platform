global:
  config:
    forensicloggingsidecar_disabled: true

account-lookup-service:
  account-lookup-service:
    containers:
    config:
      db_password: "${account_lookup_db_password}"
      db_host: "${account_lookup_db_host}"
      db_user: "${account_lookup_db_user}"
      db_port: 3306
      endpointSecurity:
        jwsSigningKey: |-
          ${indent(10, jws_signing_priv_key)}
      protocol_versions: {
        "CONTENT": {
          "DEFAULT": "1.1",
          "VALIDATELIST": [
            "1",
            "1.0",
            "1.1"
          ]
        },
        "ACCEPT": {
          "DEFAULT": "1",
          "VALIDATELIST": [
            "1",
            "1.0",
            "1.1"
          ]
        }
      }
      # Thirdparty API Config
      featureEnableExtendedPartyIdType: ${mojaloop_thirdparty_support_enabled}
    ingress:
      annotations:
        kubernetes.io/ingress.class: nginx
      hosts:
        - account-lookup-service.${env}.${name}.${domain}.internal
  account-lookup-service-admin:
    containers:
    config:
      db_password: "${account_lookup_db_password}"
      db_host: "${account_lookup_db_host}"
      db_user: "${account_lookup_db_user}"
      db_port: 3306

      # Protocol versions used for validating (VALIDATELIST) incoming FSPIOP API Headers (Content-type, Accept),
      # and for generating requests/callbacks from the Switch itself (DEFAULT value)
      protocol_versions: {
        "CONTENT": {
          "DEFAULT": "1.1",
          "VALIDATELIST": [
            "1",
            "1.0",
            "1.1"
          ]
        },
        "ACCEPT": {
          "DEFAULT": "1",
          "VALIDATELIST": [
            "1",
            "1.0",
            "1.1"
          ]
        }
      }
      # Thirdparty API Config
      featureEnableExtendedPartyIdType: ${mojaloop_thirdparty_support_enabled}
    ingress:
      annotations:
        kubernetes.io/ingress.class: nginx
      hosts:
        - account-lookup-service-admin.${env}.${name}.${domain}.internal
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
      kafka_port: 9092
      mongo_host: ${cep_mongodb_host}
      mongo_port: 27017
      mongo_user: ${cep_mongodb_user}
      mongo_password: ${cep_mongodb_pass}
      mongo_database: ${cep_mongodb_database}
    ingress:
      annotations:
        kubernetes.io/ingress.class: nginx
      hosts:
        api: central-event-processor.${env}.${name}.${domain}.internal
  centralledger:
    centralledger-handler-admin-transfer:
      config:
        kafka_host: "${kafka_host}"
        kafka_port: 9092
        db_password: "${central_ledger_db_password}"
        db_host: "${central_ledger_db_host}"
        db_user: "${central_ledger_db_user}"
        db_port: 3306
        db_database: central_ledger
      ingress:
        annotations:
          kubernetes.io/ingress.class: nginx
        hosts:
          api: central-ledger-admin-transfer.${env}.${name}.${domain}.internal
    centralledger-handler-timeout:
      config:
        kafka_host: "${kafka_host}"
        kafka_port: 9092
        db_password: "${central_ledger_db_password}"
        db_host: "${central_ledger_db_host}"
        db_user: "${central_ledger_db_user}"
        db_port: 3306
        db_database: central_ledger
      ingress:
        annotations:
          kubernetes.io/ingress.class: nginx
        hosts:
          api: central-ledger-timeout.${env}.${name}.${domain}.internal
    centralledger-handler-transfer-fulfil:
      config:
        kafka_host: "${kafka_host}"
        kafka_port: 9092
        db_password: "${central_ledger_db_password}"
        db_host: "${central_ledger_db_host}"
        db_user: "${central_ledger_db_user}"
        db_port: 3306
        db_database: central_ledger
      ingress:
        annotations:
          kubernetes.io/ingress.class: nginx
        hosts:
          api: central-ledger-transfer-fulfil.${env}.${name}.${domain}.internal
    centralledger-handler-transfer-get:
      config:
        kafka_host: "${kafka_host}"
        kafka_port: 9092
        db_password: "${central_ledger_db_password}"
        db_host: "${central_ledger_db_host}"
        db_user: "${central_ledger_db_user}"
        db_port: 3306
        db_database: central_ledger
      ingress:
        annotations:
          kubernetes.io/ingress.class: nginx
        hosts:
          api: central-ledger-transfer-get.${env}.${name}.${domain}.internal
    centralledger-handler-transfer-position:
      config:
        kafka_host: "${kafka_host}"
        kafka_port: 9092
        db_password: "${central_ledger_db_password}"
        db_host: "${central_ledger_db_host}"
        db_port: 3306
        db_user: "${central_ledger_db_user}"
        db_database: central_ledger
      ingress:
        annotations:
          kubernetes.io/ingress.class: nginx
        hosts:
          api: central-ledger-transfer-position.${env}.${name}.${domain}.internal
    centralledger-handler-transfer-prepare:
      config:
        kafka_host: "${kafka_host}"
        kafka_port: 9092
        db_password: "${central_ledger_db_password}"
        db_host: "${central_ledger_db_host}"
        db_port: 3306
        db_user: "${central_ledger_db_user}"
        db_database: central_ledger
      ingress:
        annotations:
          kubernetes.io/ingress.class: nginx
        hosts:
          api: central-ledger-transfer-prepare.${env}.${name}.${domain}.internal
    centralledger-service:
      config:
        kafka_host: "${kafka_host}"
        kafka_port: 9092
        db_password: "${central_ledger_db_password}"
        db_host: "${central_ledger_db_host}"
        db_port: 3306
        db_user: "${central_ledger_db_user}"
        db_database: central_ledger
      ingress:
        annotations:
          nginx.ingress.kubernetes.io/rewrite-target: /$2
          kubernetes.io/ingress.class: nginx
        externalPath:
            api: /admin(/|$)(.*)
        hosts:
          api: interop-switch.${env}.${name}.${domain}.internal
          admin: interop-switch.${env}.${name}.${domain}.internal

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
          api: interop-switch.${env}.${name}.${domain}.internal
      config:
        kafka_host: "${kafka_host}"
        kafka_port: 9092
        db_password: "${central_settlement_db_password}"
        db_host: "${central_settlement_db_host}"
        db_port: 3306
        db_user: "${central_settlement_db_user}"
        db_database: central_ledger
    centralsettlement-handler-deferredsettlement:
      config:
        kafka_host: "${kafka_host}"
        kafka_port: 9092
        db_password: "${central_settlement_db_password}"
        db_host: "${central_settlement_db_host}"
        db_user: "${central_settlement_db_user}"
        db_port: 3306
        db_database: central_ledger
    centralsettlement-handler-grosssettlement:
      config:
        kafka_host: "${kafka_host}"
        kafka_port: 9092
        db_password: "${central_settlement_db_password}"
        db_host: "${central_settlement_db_host}"
        db_port: 3306
        db_user: "${central_settlement_db_user}"
        db_database: central_ledger
    centralsettlement-handler-rules:
      config:
        kafka_host: "${kafka_host}"
        kafka_port: 9092
        db_password: "${central_settlement_db_password}"
        db_host: "${central_settlement_db_host}"
        db_port: 3306
        db_user: "${central_settlement_db_user}"
        db_database: central_ledger

emailnotifier:
  ingress:
    annotations:
      kubernetes.io/ingress.class: nginx
    hosts:
      api: emailnotifier.${env}.${name}.${domain}.internal
  enabled: false
  config:
    kafka_host: "${kafka_host}"
    kafka_port: 9092
    email:
      host: 'smtp.gmail.com'
      port: 587
      # secure_connection: false
      user: 'user@gmail.com'
      pass: 'pass'
      ciphers: 'SSLv3'
ml-api-adapter:
  ml-api-adapter-handler-notification:
    config:
      kafka_host: "${kafka_host}"
      kafka_port: 9092
      protocol_versions: {
        "CONTENT": {
          "DEFAULT": "1.1",
          "VALIDATELIST": [
            "1",
            "1.0",
            "1.1"
          ]
        },
        "ACCEPT": {
          "DEFAULT": "1",
          "VALIDATELIST": [
            "1",
            "1.0",
            "1.1"
          ]
        }
      }
      endpointSecurity:
        jwsSigningKey: |-
          ${indent(10, jws_signing_priv_key)}
    ingress:
      annotations:
        kubernetes.io/ingress.class: nginx
      hosts:
        api: ml-api-adapter-handler-notification.${env}.${name}.${domain}.internal
  ml-api-adapter-service:
    config:
      kafka_host: "${kafka_host}"
      kafka_port: 9092
      protocol_versions: {
        "CONTENT": {
          "DEFAULT": "1.1",
          "VALIDATELIST": [
            "1",
            "1.0",
            "1.1"
          ]
        },
        "ACCEPT": {
          "DEFAULT": "1",
          "VALIDATELIST": [
            "1",
            "1.0",
            "1.1"
          ]
        }
      }
    ingress:
      modernIngressController: true
      modernIngressControllerRegex: (/|$)(.*)
      annotations:
        nginx.ingress.kubernetes.io/rewrite-target: /$2
        kubernetes.io/ingress.class: nginx
      hosts:
        api: ml-api-adapter.${env}.${name}.${domain}.internal
quoting-service:
  config:
    simple_routing_mode_enabled: false
    log_transport: "console"
    log_level: "debug"
    kafka_host: "${kafka_host}"
    kafka_port: 9092
    db_password: "${quoting_db_password}"
    db_host: "${quoting_db_host}"
    db_port: 3306
    db_user: "${quoting_db_user}"
    db_user: central_ledger
    endpointSecurity:
      jwsSigningKey: |-
        ${indent(8, jws_signing_priv_key)}
    protocol_versions: {
      "CONTENT": {
        "DEFAULT": "1.1",
        "VALIDATELIST": [
          "1",
          "1.0",
          "1.1"
        ]
      },
      "ACCEPT": {
        "DEFAULT": "1",
        "VALIDATELIST": [
          "1",
          "1.0",
          "1.1"
        ]
      }
    }
  ingress:
    annotations:
      kubernetes.io/ingress.class: nginx
    hosts:
      api: quoting-service.${env}.${name}.${domain}.internal

simulator:
  ingress:
    annotations:
      kubernetes.io/ingress.class: nginx
    hosts:
      - moja-simulator.${env}.${name}.${domain}.internal

finance-portal:
  enabled: false
finance-portal-settlement-management:
  enabled: false
mojaloop-bulk:
  enabled: true
  mongodb:
    enabled: false
  bulk-centralledger:
    cl-handler-bulk-transfer-get:
      config:
        kafka_host: "${kafka_host}"
        kafka_port: 9092
        db_password: "${central_ledger_db_password}"
        db_host: "${central_ledger_db_host}"
        db_port: 3306
        db_user: "${central_ledger_db_user}"
        db_database: central_ledger
        objstore_uri: 'mongodb://${cl_mongodb_user}:${cl_mongodb_pass}@${cl_mongodb_host}:27017/${cl_mongodb_database}'
    cl-handler-bulk-transfer-prepare:
      config:
        kafka_host: "${kafka_host}"
        kafka_port: 9092
        db_password: "${central_ledger_db_password}"
        db_host: "${central_ledger_db_host}"
        db_port: 3306
        db_user: "${central_ledger_db_user}"
        db_database: central_ledger
        objstore_uri: 'mongodb://${cl_mongodb_user}:${cl_mongodb_pass}@${cl_mongodb_host}:27017/${cl_mongodb_database}'
    cl-handler-bulk-transfer-fulfil:
      config:
        kafka_host: "${kafka_host}"
        kafka_port: 9092
        db_password: "${central_ledger_db_password}"
        db_host: "${central_ledger_db_host}"
        db_port: 3306
        db_user: "${central_ledger_db_user}"
        db_database: central_ledger
        objstore_uri: 'mongodb://${cl_mongodb_user}:${cl_mongodb_pass}@${cl_mongodb_host}:27017/${cl_mongodb_database}'
    cl-handler-bulk-transfer-processing:
      config:
        kafka_host: "${kafka_host}"
        kafka_port: 9092
        db_password: "${central_ledger_db_password}"
        db_host: "${central_ledger_db_host}"
        db_port: 3306
        db_user: "${central_ledger_db_user}"
        db_database: central_ledger
        objstore_uri: 'mongodb://${cl_mongodb_user}:${cl_mongodb_pass}@${cl_mongodb_host}:27017/${cl_mongodb_database}'
  bulk-api-adapter:
    bulk-api-adapter-handler-notification:
      config:
        kafka_host: "${kafka_host}"
        kafka_port: 9092
        objstore_uri: 'mongodb://${cl_mongodb_user}:${cl_mongodb_pass}@${cl_mongodb_host}:27017/${cl_mongodb_database}'
        protocol_versions: {
          "CONTENT": {
            "DEFAULT": "1.1",
            "VALIDATELIST": [
              "1",
              "1.0",
              "1.1"
            ]
          },
          "ACCEPT": {
            "DEFAULT": "1",
            "VALIDATELIST": [
              "1",
              "1.0",
              "1.1"
            ]
          }
        }
    bulk-api-adapter-service:
      config:
        kafka_host: "${kafka_host}"
        kafka_port: 9092
        objstore_uri: 'mongodb://${cl_mongodb_user}:${cl_mongodb_pass}@${cl_mongodb_host}:27017/${cl_mongodb_database}'
        protocol_versions: {
          "CONTENT": {
            "DEFAULT": "1.1",
            "VALIDATELIST": [
              "1",
              "1.0",
              "1.1"
            ]
          },
          "ACCEPT": {
            "DEFAULT": "1",
            "VALIDATELIST": [
              "1",
              "1.0",
              "1.1"
            ]
          }
        }
      ingress:
        annotations:
          kubernetes.io/ingress.class: nginx
        hosts:
          api: bulk-api-adapter.${env}.${name}.${domain}.internal

transaction-requests-service:
  config:
    protocol_versions: {
      "CONTENT": {
        "DEFAULT": "1.1",
        "VALIDATELIST": [
          "1",
          "1.0",
          "1.1"
        ]
      },
      "ACCEPT": {
        "DEFAULT": "1",
        "VALIDATELIST": [
          "1",
          "1.0",
          "1.1"
        ]
      }
    }
  ingress:
    annotations:
      kubernetes.io/ingress.class: nginx
    hosts:
      api: transaction-request-service.${env}.${name}.${domain}.internal

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
      enabled: false

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
      enabled: false

  tp-api-svc:
    enabled: true
    config:
      default.json: {
      # Static list of participantIds that support account linking
      "PARTICIPANT_LIST_LOCAL": [
        "dfspa",
        "dfspb"
      ],
      "MOCK_CALLBACK": {
        "transactionRequestId": "abc-12345",
        "pispId": "pisp"
      }
    }

    ingress:
      enabled: true
      annotations:
        kubernetes.io/ingress.class: nginx
      hosts:
        - host: tp-api-svc.${env}.${name}.${domain}.internal
          port: 3008
          name: tp-api-svc
          paths: ['/']

