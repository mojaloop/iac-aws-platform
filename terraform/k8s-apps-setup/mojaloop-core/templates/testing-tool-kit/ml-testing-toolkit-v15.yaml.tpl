# Custom YAML TEMPLATE Anchors
CONFIG:
  ## TTK MONGODB BACKEND
  ttk_mongo_host: &TTK_MONGO_HOST "${ttk_mongodb_host}"
  ttk_mongo_port: &TTK_MONGO_PORT ${ttk_mongodb_port}
  ttk_mongo_user: &TTK_MONGO_USER "${ttk_mongodb_user}"
  ttk_mongo_password: &TTK_MONGO_PASSWORD "${ttk_mongodb_pass}"
  ## TODO: Enable the following secret file and remove the above plain text password
  # ttk_mongo_secret: &TTK_MONGO_SECRET
  #   name: &TTK_MONGO_SECRET_NAME ttk-mongodb
  #   key: &TTK_MONGO_SECRET_KEY mongodb-passwords
  ttk_mongo_database: &TTK_MONGO_DATABASE "${ttk_mongodb_database}"

ml-testing-toolkit:
  enabled: ${internal_ttk_enabled}
  ml-testing-toolkit-backend:
    config:
      mongodb:
        host: *TTK_MONGO_HOST
        port: *TTK_MONGO_PORT
        user: *TTK_MONGO_USER
        password: *TTK_MONGO_PASSWORD
        ## TODO: Enable the following secret file and remove the above plain text password
        # secret: *TTK_MONGO_SECRET
        database: *TTK_MONGO_DATABASE
    ingress:
      enabled: true
      hosts:
        specApi:
          host: ttkbackend.${private_subdomain}
        adminApi:
          host: ttkbackend.${private_subdomain}
    parameters: &simNames
      simNamePayerfsp: 'payerfsp'
      simNamePayeefsp: 'payeefsp'
      simNameTestfsp1: 'testfsp1'
      simNameTestfsp2: 'testfsp2'
      simNameTestfsp3: 'testfsp3'
      simNameTestfsp4: 'testfsp4'
      simNameNoResponsePayeefsp: 'noresponsepayeefsp'
      simNameTTKSim1: 'ttksim1'
      simNameTTKSim2: 'ttksim2'
      simNameTTKSim3: 'ttksim3'
    extraEnvironments:
      hub-k8s-cgs-environment.json: null
      hub-k8s-default-environment.json: &ttkInputValues {
        "inputValues": {
          "SIMPAYER_CURRENCY": "${ttk_test_currency1}",
          "SIMPAYEE_CURRENCY": "${ttk_test_currency1}",
          "currency": "${ttk_test_currency1}",
          "currency2": "${ttk_test_currency2}",
          "cgscurrency": "${ttk_test_currency3}",
          "SIMPLE_ROUTING_MODE_ENABLED": ${quoting_service_simple_routing_mode_enabled},
          "ON_US_TRANSFERS_ENABLED": false,
          "NET_DEBIT_CAP": "10000000",
          "accept": "application/vnd.interoperability.parties+json;version=1.1",
          "acceptParties": "application/vnd.interoperability.parties+json;version=1.1",
          "acceptPartiesOld": "application/vnd.interoperability.parties+json;version=1.0",
          "acceptPartiesNotSupported": "application/vnd.interoperability.parties+json;version=2.0",
          "acceptParticipants": "application/vnd.interoperability.participants+json;version=1.1",
          "acceptParticipantsOld": "application/vnd.interoperability.participants+json;version=1.0",
          "acceptParticipantsNotSupported": "application/vnd.interoperability.participants+json;version=2.0",
          "acceptQuotes": "application/vnd.interoperability.quotes+json;version=1.1",
          "acceptQuotesOld": "application/vnd.interoperability.quotes+json;version=1.0",
          "acceptQuotesNotSupported": "application/vnd.interoperability.quotes+json;version=2.0",
          "acceptTransfers": "application/vnd.interoperability.transfers+json;version=1.1",
          "acceptTransfersOld": "application/vnd.interoperability.transfers+json;version=1.0",
          "acceptTransfersNotSupported": "application/vnd.interoperability.transfers+json;version=2.0",
          "acceptTransactionRequests": "application/vnd.interoperability.transactionRequests+json;version=1.1",
          "acceptTransactionRequestsOld": "application/vnd.interoperability.transactionRequests+json;version=1.0",
          "acceptTransactionRequestsNotSupported": "application/vnd.interoperability.transactionRequests+json;version=2.0",
          "acceptAuthorizations": "application/vnd.interoperability.authorizations+json;version=1.1",
          "acceptAuthorizationsOld": "application/vnd.interoperability.authorizations+json;version=1.0",
          "acceptAuthorizationsNotSupported": "application/vnd.interoperability.authorizations+json;version=2.0",
          "acceptBulkTransfers": "application/vnd.interoperability.bulkTransfers+json;version=1.1",
          "acceptBulkTransfersOld": "application/vnd.interoperability.bulkTransfers+json;version=1.0",
          "acceptBulkTransfersNotSupported": "application/vnd.interoperability.bulkTransfers+json;version=2.0",
          "contentType": "application/vnd.interoperability.parties+json;version=1.1",
          "contentTypeTransfers": "application/vnd.interoperability.transfers+json;version=1.1",
          "contentTypeTransfersOld": "application/vnd.interoperability.transfers+json;version=1.0",
          "contentTypeTransfersNotSupported": "application/vnd.interoperability.transfers+json;version=2.0",
          "contentTypeParties": "application/vnd.interoperability.parties+json;version=1.1",
          "contentTypePartiesOld": "application/vnd.interoperability.parties+json;version=1.0",
          "contentTypePartiesNotSupported": "application/vnd.interoperability.parties+json;version=2.0",
          "contentTypeParticipants": "application/vnd.interoperability.participants+json;version=1.1",
          "contentTypeParticipantsOld": "application/vnd.interoperability.participants+json;version=1.0",
          "contentTypeParticipantsNotSupported": "application/vnd.interoperability.participants+json;version=2.0",
          "contentTypeQuotes": "application/vnd.interoperability.quotes+json;version=1.1",
          "contentTypeQuotesOld": "application/vnd.interoperability.quotes+json;version=1.0",
          "contentTypeQuotesNotSupported": "application/vnd.interoperability.quotes+json;version=2.0",
          "contentTypeTransactionRequests": "application/vnd.interoperability.transactionRequests+json;version=1.1",
          "contentTypeTransactionRequestsOld": "application/vnd.interoperability.transactionRequests+json;version=1.0",
          "contentTypeTransactionRequestsNotSupported": "application/vnd.interoperability.transactionRequests+json;version=2.0",
          "contentTypeAuthorizations": "application/vnd.interoperability.authorizations+json;version=1.1",
          "contentTypeAuthorizationsOld": "application/vnd.interoperability.authorizations+json;version=1.0",
          "contentTypeAuthorizationsNotSupported": "application/vnd.interoperability.authorizations+json;version=2.0",
          "contentBulkTransfers": "application/vnd.interoperability.bulkTransfers+json;version=1.1",
          "contentBulkTransfersOld": "application/vnd.interoperability.bulkTransfers+json;version=1.0",
          "contentBulkTransfersNotSupported": "application/vnd.interoperability.bulkTransfers+json;version=2.0",
          "expectedPartiesVersion": "1.1",
          "expectedParticipantsVersion": "1.1",
          "expectedQuotesVersion": "1.1",
          "expectedTransfersVersion": "1.1",
          "expectedAuthorizationsVersion": "1.1",
          "expectedTransactionRequestsVersion": "1.1"
        }
      }

  ml-testing-toolkit-frontend:
    ingress:
      enabled: true
      hosts:
        ui: 
          host: ttkfrontend.${private_subdomain}
          port: 6060
          paths: ['/']
    config:
      API_BASE_URL: http://ttkbackend.${private_subdomain}

ml-ttk-test-setup:
  tests:
    enabled: true
    weight: -6
  parameters:
    <<: *simNames
  testCaseEnvironmentFile:  *ttkInputValues

ml-ttk-test-val-gp:
  tests:
    enabled: true
    weight: -5
  config:
    testSuiteName: GP Tests
    environmentName: QA
  parameters:
    <<: *simNames
  testCaseEnvironmentFile:  *ttkInputValues

# ml-ttk-test-val-bulk:
#   tests:
#     enabled: true

# ml-ttk-test-setup-tp:
#   tests:
#     enabled: true

# ml-ttk-test-val-tp:
#   tests:
#     enabled: true