ml-testing-toolkit:
  enabled: ${internal_ttk_enabled}
  ml-testing-toolkit-backend:
    image:
      repository: mojaloop/ml-testing-toolkit
      tag: v14.0.5
    ingress:
      hosts:
        specApi:
          host: ttkbackend.${private_subdomain}
          port: 5000
          paths: ['/']
        adminApi:
          host: ttkbackend.${private_subdomain}
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
              "endpoint": "http://$release_name-account-lookup-service"
            },
            {
              "method": "put",
              "path": "/quotes/{ID}",
              "endpoint": "http://$release_name-quoting-service"
            },
            {
              "method": "put",
              "path": "/transfers/{ID}",
              "endpoint": "http://$release_name-ml-api-adapter-service"
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
        "CLIENT_MUTUAL_TLS_ENABLED": false,
        "ADVANCED_FEATURES_ENABLED": true,
        "CALLBACK_TIMEOUT": 20000,
        "DEFAULT_REQUEST_TIMEOUT": 5000,
        "SCRIPT_TIMEOUT": 5000,
        "LOG_SERVER_UI_URL": "${kibana_url}",
        "UI_CONFIGURATION": {
          "MOBILE_SIMULATOR": {
            "HUB_CONSOLE_ENABLED": true
          }
        },
        "CLIENT_TLS_CREDS": [
          {
            "HOST": "testfsp1",
            "CERT": "-----BEGIN CERTIFICATE-----\nMIIFATCCAumgAwIBAgIUEcEtqgcXBoTykvaD6PprzY8kxpYwDQYJKoZIhvcNAQEL\nBQAwfzERMA8GA1UEChMITW9kdXNCb3gxHDAaBgNVBAsTE0luZnJhc3RydWN0dXJl\nIFRlYW0xTDBKBgNVBAMTQ3Rlc3Rmc3AxLnFhLnByZS5teWFubWFycGF5LXByZS5p\nby5pbnRlcm5hbCB0ZXN0ZnNwMSBJbnRlcm1lZGlhdGUgQ0EwHhcNMjEwMjIyMTkw\nMTEyWhcNMjMwMjIzMDY0MDA2WjBdMREwDwYDVQQKEwhNb2R1c0JveDEcMBoGA1UE\nCxMTSW5mcmFzdHJ1Y3R1cmUgVGVhbTEqMCgGA1UEAxMhdGVzdGZzcDEucWEucHJl\nLm15YW5tYXJwYXktcHJlLmlvMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKC\nAQEApndEBbmdlfrpnidagKb2D32bEL+iGYxLEicdQVs24018zNPdbrIYtXyDjgjA\nq718HH5XQW2FSz6cA1CbQ6jLuY88EZRUiCSJ4rCkENWw+mpVLyOd+mcYU4JwOQNC\nP+W8GGcW/haifkXtHEDUO4pIxnXWC6DftvxZ3TH5PxtWO8aJcsoj94oBTPOhnGi0\nC356XyseYl7o7hdxZu3DvY3Wyh/k5pDDHOCjQYxl9wjtW+BVWMCFxRaCu4f/3LVj\nca9BccwZ8O4Rdhu6lhJEUCUgTqdx3vXRB1xzwHT0W7gariy4RVbvwE35AaCliyEr\n4O5WlCvAMOct7POYDAwNuoeb7wIDAQABo4GWMIGTMA4GA1UdDwEB/wQEAwIDqDAT\nBgNVHSUEDDAKBggrBgEFBQcDAjAdBgNVHQ4EFgQU2alVxVOOplYXiLAYCDaII4E0\n/WgwHwYDVR0jBBgwFoAUCFvcCetcirxZPE3N6qMdOo5H7Z4wLAYDVR0RBCUwI4Ih\ndGVzdGZzcDEucWEucHJlLm15YW5tYXJwYXktcHJlLmlvMA0GCSqGSIb3DQEBCwUA\nA4ICAQBkX5LItY0calp7NT21O8z+iufVNV8onEch4J7HJjEVwtCB4UVl7LrWJ3cw\n9KLt7nj85/AUuuhtNPJO9DW/x+0xRyW94Ef5MYHP3nheFWTag8riYl/1SXljOssS\nHCpTvRhirnfGeqBGO1OBwCbkYNIEZI95eMerVoPFm0PfGBb4DJ6mUdfc3qzeOP7K\nOlE5VMhwH2PYv1TS7Hpj1k/1dxpdvyOs7EKVvWD+OokLhJaHgU8NWVetTUtsXSN/\nTv06ZN8JGTN/Udm7POVyEaol8Jw2FRGGKcwOBKbqroNs6POqTofqZeL4SFAkzzQL\nvOAhbQIB6GSznG1Gg1G9IjGVCMXUhpNK2PD8RR1ovzi0MZlRkITGRPhBYQf5xMFl\nZeq0mGFQR3VYDdlwT0O37C8fpaYvpdupeYdxcB623PNz1VkO1MbsXnOoHY8kcFGa\nMh4IARCeR/MwXNWHpGrd6J5Mzmhk0Vy8GyBbqcROUpNR/XTZYRTyfTEq5+amJyLi\n67OB9FP5cS7oQhj7gsaQCTJlxbh/CjmQdKmIimWSEZkDePK5eExNPafBk47tx4KA\nFmh9pIqRyheROesa/zTDGYySNcVd14dl703pyZQNO4b5rap0SZoyGDTfI+7OqAHM\nAz0kWYyZps2nqPZgbwDFigIy2TESvoXahCCtNUoCy9sawa3Diw==\n-----END CERTIFICATE-----",
            "KEY": "-----BEGIN RSA PRIVATE KEY-----\nMIIEpAIBAAKCAQEApndEBbmdlfrpnidagKb2D32bEL+iGYxLEicdQVs24018zNPd\nbrIYtXyDjgjAq718HH5XQW2FSz6cA1CbQ6jLuY88EZRUiCSJ4rCkENWw+mpVLyOd\n+mcYU4JwOQNCP+W8GGcW/haifkXtHEDUO4pIxnXWC6DftvxZ3TH5PxtWO8aJcsoj\n94oBTPOhnGi0C356XyseYl7o7hdxZu3DvY3Wyh/k5pDDHOCjQYxl9wjtW+BVWMCF\nxRaCu4f/3LVjca9BccwZ8O4Rdhu6lhJEUCUgTqdx3vXRB1xzwHT0W7gariy4RVbv\nwE35AaCliyEr4O5WlCvAMOct7POYDAwNuoeb7wIDAQABAoIBAB4YIawHSn36xpFY\n+/uWM5XJV2dHvb5wpoG5oIhYPSwKri05gCaq+9yTjhT3cB2cO/vKu2uQqTBZOUtA\nH1G0CmCZjHqBHmcec+8PkBmbCEu9PXkwLzc9vCAczL0B4dA7cC3ZNUbqQKYjbiJV\ndgjtjwqR8whXJRqntHdQuYa3InfbufcHNHhSXJwE9MqVRpsv/BfY9wjhQfGBHUnT\nCz41xj1bu8Uy4+/1sRF/l9fYDm5E6WbgzvI49/fM7hA+8fQqoRkFLlEzzBhWb93Q\n2qVo2Y5RhVpffdyxPYX7b9RI7UmUZYp2sLl5GYj5ZzTzsffwUdPl2pZlRkYJGvUo\nortpToECgYEA17NVIZgeQ5VcSsZKGJlzPkcdPoWCk7RY5DugxTaNwSE/uO25B/Ax\nBPE6ZC9LbfXyfTQXaam2VtpSzvNJ7p7j30qkEK0Z+I2pGAVohZg4enkHaIQkYtIP\naZZ/wce5R8VZq6EpToprTm3cG6T+nNVOzqRjUqgnUZyY8nWy2CD5OucCgYEAxZEb\nOKjo9Iwrod2uOZlQDAsnTvgqZySW/lORrnfEWmOEiJpRvjlxMfNPNlc2iMTBQShq\naPZi48g17btU8ACs2NOH/FXuxooDe+0gJDj48WP9/bBzOAOJqhKZ+g9l/Cr978yJ\nAHNh/w8foUUkqAfxmXoTImw7LdSaPIc7ewAlPbkCgYAcGq6d6O8QiTZ0O6/N0riU\nRbnGuqiPzDDE1AwXhgskPcvKsZapNR998FxWT185nZERxSbDyqwKVvnxIvvgDm3M\nWzJTReqbWwHMMnAy7+lz868GbCk9gvclH8nXmslGU61iUmZKaHigyGmkZHQURSq2\ne+7BB03QMWIwPSunQ2yVwwKBgQCbPrzvNvtnPsYCeZmwNSLLc/A9g5B+YCguTSjK\nud4XUOASH4FgQu8J2zFBeCKoMkPRmZqURBfM+cQ2vN+vgDhSYVYYGMZ6SHUYamq5\nS/OCa5poQMEpIM6KT/eioXr4PigwyL5XFlPJAu9N4HE/gI5+lYh3oiiWiNtx+Knq\nq2CYMQKBgQCv+QTGDrSc3SUaWT+JMoFdfzvJyyqQOUvgRbSGAp5GryYqI9dozx70\nlT2IdoAZ0DHrJhNs13Pr7ngXwqS6pKlZU8NSX2ch7h5ZwIsYJESzKwXF/frLMQSy\nTPV3d0hb7UaW3wqOx2Dbj8vJJdvUo3UUkOcmgesqGg3nf3t51I6k0A==\n-----END RSA PRIVATE KEY-----"
          }
        ],
        "GITHUB_CONFIG": {
          "TEST_CASES_REPO_OWNER": "mojaloop",
          "TEST_CASES_REPO_NAME": "testing-toolkit-test-cases",
          "TEST_CASES_REPO_DEFAULT_RELEASE_TAG": "v13.0.2",
          "TEST_CASES_REPO_BASE_PATH": "collections/hub",
          "TEST_CASES_REPO_HUB_GP_PATH": "collections/hub/golden_path",
          "TEST_CASES_REPO_HUB_PROVISIONING_PATH": "collections/hub/provisioning"
        },
        "DEFAULT_ENVIRONMENT_FILE_NAME": "hub-k8s-default-environment.json",
        "LABELS": [
          {
            "name": "p2p",
            "description": "Tests related to p2p transfer",
            "color": "red"
          },
          {
            "name": "settlements",
            "description": "Tests related to settlements",
            "color": "green"
          },
          {
            "name": "quotes",
            "description": "Tests related to quoting service",
            "color": "blue"
          }
        ]
      }
      system_config.json: {
        "API_PORT": 5000,
        "HOSTING_ENABLED": false,
        "INBOUND_MUTUAL_TLS_ENABLED": false,
        "OUTBOUND_MUTUAL_TLS_ENABLED": false,
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
          "OAUTH2_TOKEN_ISS": "http://$auth_host:$auth_port$auth_token_iss_path",
          "OAUTH2_ISSUER": "http://$auth_host:$auth_port$auth_issuer_path",
          "EMBEDDED_CERTIFICATE": "$auth_embedded_certificate"
        },
        "KEYCLOAK": {
          "ENABLED": false,
          "API_URL": "http://$auth_host:$auth_port",
          "REALM": "testingtoolkit",
          "ADMIN_REALM": "master",
          "ADMIN_USERNAME": "admin",
          "ADMIN_PASSWORD": "admin",
          "ADMIN_CLIENT_ID": "admin-cli"
        },
        "SERVER_LOGS": {
          "ENABLED": true,
          "RESULTS_PAGE_SIZE": 50,
          "ADAPTER": {
            "TYPE": "ELASTICSEARCH",
            "INDEX": "mojaloop*",
            "API_URL": "${elasticsearch_url}"
          }
        },
        "CONNECTION_MANAGER": {
          "ENABLED": false,
          "API_URL": "http://$connection_manager_host:$connection_manager_port",
          "AUTH_ENABLED": false,
          "HUB_USERNAME": "hub",
          "HUB_PASSWORD": "hub"
        },
        "HTTP_CLIENT": {
          "KEEP_ALIVE": false,
          "MAX_SOCKETS": 50,
          "UNUSED_AGENTS_EXPIRY_MS": 1800000,
          "UNUSED_AGENTS_CHECK_TIMER_MS": 300000
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
            "type": "settlements",
            "version": "2.0",
            "folderPath": "settlements_2.0"
          },
          {
            "type": "central_admin",
            "caption": "(old)",
            "version": "9.3",
            "folderPath": "central_admin_old_9.3"
          },
          {
            "type": "central_admin",
            "version": "1.0",
            "folderPath": "central_admin_1.0"
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
          },
          {
            "type": "mojaloop_sdk_outbound_scheme_adapter",
            "version": "1.0",
            "folderPath": "mojaloop_sdk_outbound_scheme_adapter_1.0"
          },
          {
            "type": "payment_manager",
            "version": "1.4",
            "folderPath": "payment_manager_1.4"
          },
          {
            "type": "thirdparty_sdk_outbound",
            "version": "0.1",
            "folderPath": "thirdparty_sdk_outbound_0.1"
          }
        ]
      }

    parameters: &simNames
      simNamePayerfsp: 'payerfsp'
      simNamePayeefsp: 'payeefsp'
      simNameTestfsp1: 'testfsp1'
      simNameTestfsp2: 'testfsp2'
      simNameTestfsp3: 'testfsp3'
      simNameTestfsp4: 'testfsp4'
      simNameNoResponsePayeefsp: 'noresponsepayeefsp'
    extraEnvironments:
      hub-k8s-cgs-environment.json: null
      hub-k8s-default-environment.json: {
        "inputValues": {
          "SIMPAYER_CURRENCY": "XXX",
          "SIMPAYEE_CURRENCY": "XXX",
          "currency": "XXX",
          "currency2": "XTS",
          "SIMPLE_ROUTING_MODE_ENABLED": true,
          "ON_US_TRANSFERS_ENABLED": false
        }
      }

  ml-testing-toolkit-frontend:
    image:
      repository: mojaloop/ml-testing-toolkit-ui
      tag: v13.5.5
    ingress:
      hosts:
        ui: 
          host: ttkfrontend.${private_subdomain}
          port: 6060
          paths: ['/']
    config:
      API_BASE_URL: http://ttkbackend.${private_subdomain}

ml-ttk-test-setup:
  parameters:
    <<: *simNames

ml-ttk-test-validation:
  config:
    testSuiteName: GP Tests
    environmentName: QA
  parameters:
    <<: *simNames
