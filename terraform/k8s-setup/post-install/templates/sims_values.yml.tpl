ingress:
  ingressPathRewriteRegex: "(/|$)(.*)"
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /$2
    nginx.ingress.kubernetes.io/use-regex: "true"

simulators:
  ${name}:
    ingress:
      enabled: "${INGRESS_ENABLED}"
      hosts: ["${INGRESS_HOST}"]
    config:
      schemeAdapter:
        env:
          SIM_BACKEND_SERVICE_NAME: ${SIM_BACKEND_SERVICE_NAME}
          SIM_CACHE_SERVICE_NAME: ${SIM_CACHE_SERVICE_NAME}
          JWS_SIGN: true
          PEER_ENDPOINT: ${PEER_ENDPOINT}
          DFSP_ID: ${name}
          ILP_SECRET: "Quaixohyaesahju3thivuiChai5cahng"
          AUTO_ACCEPT_QUOTES: true
          AUTO_ACCEPT_PARTY: true
          USE_QUOTE_SOURCE_FSP_AS_TRANSFER_PAYEE_FSP: true
          INBOUND_MUTUAL_TLS_ENABLED: false
          OUTBOUND_MUTUAL_TLS_ENABLED: true
          VALIDATE_INBOUND_JWS: false
          OAUTH_CLIENT_KEY: ${OAUTH_CLIENT_KEY}
          OAUTH_CLIENT_SECRET: ${OAUTH_CLIENT_SECRET}
          OAUTH_TOKEN_ENDPOINT: ${OAUTH_TOKEN_ENDPOINT}
        secrets:
          jws:
            privKeySecretName: ${PRIV_KEY_SECRET_NAME}
            publicKeyConfigMapName: ${PUBLIC_KEY_CONFIG_MAP_NAME}
          tlsSecretName: ${TLS_SECRET_NAME}
      backend:
        env:
          SIM_SCHEME_ADAPTER_SERVICE_NAME: ${SIM_SCHEME_ADAPTER_SERVICE_NAME}
          SIM_CACHE_SERVICE_NAME: ${SIM_CACHE_SERVICE_NAME}
        rules: |-
          [
            {
              "ruleId": 1,
              "description": "Returns an NDC exceeded error response (ML error 4001) from the simulator when transfer value is 123 in any currency",
              "conditions": {
                "all": [
                  {
                    "fact": "path",
                    "operator": "equal",
                    "value": "/transfers"
                  },
                  {
                    "fact": "method",
                    "operator": "equal",
                    "value": "POST"
                  },
                  {
                    "fact": "body",
                    "operator": "equal",
                    "value": "123",
                    "path": ".amount"
                  }
                ]
              },
              "event": {
                "type": "simulateError",
                "params": {
                  "statusCode": 500,
                  "body": {
                    "statusCode": "4001",
                    "message": "Payer FSP insufficient liquidity"
                  }
                }
              }
            },
            {
              "ruleId": 2,
              "description": "Triggers a destination DFSP not found error response (ML error 3201) from the simulator when a party is looked up by MSISDN 000000000 (9 zeros)",
              "conditions": {
                "all": [
                  {
                    "fact": "path",
                    "operator": "equal",
                    "value": "/parties/MSISDN/000000000"
                  },
                  {
                    "fact": "method",
                    "operator": "equal",
                    "value": "GET"
                  }
                ]
              },
              "event": {
                "type": "simulateError",
                "params": {
                  "statusCode": 500,
                  "body": {
                    "statusCode": "3201",
                    "message": "Destination FSP not found"
                  }
                }
              }
            },
            {
              "ruleId": 3,
              "description": "Triggers a party not found error response (ML error 3204) from the simulator when a party is looked up by MSISDN 000000001 (8 zeros and a 1)",
              "conditions": {
                "all": [
                  {
                    "fact": "path",
                    "operator": "equal",
                    "value": "/parties/MSISDN/000000001"
                  },
                  {
                    "fact": "method",
                    "operator": "equal",
                    "value": "GET"
                  }
                ]
              },
              "event": {
                "type": "simulateError",
                "params": {
                  "statusCode": 500,
                  "body": {
                    "statusCode": "3204",
                    "message": "Party not found"
                  }
                }
              }
            },
            {
              "ruleId": 4,
              "description": "Causes no response from the simulator when a party is looked up by MSISDN 919951935307 (8 zeros and a 2)",
              "conditions": {
                "all": [
                  {
                    "fact": "path",
                    "operator": "equal",
                    "value": "/parties/MSISDN/919951935307"
                  },
                  {
                    "fact": "method",
                    "operator": "equal",
                    "value": "GET"
                  }
                ]
              },
              "event": {
                "type": "simulateNoResponse",
                "params": {
                  "noResponse": true
                }
              }
            },
            {
              "ruleId": 5,
              "description": "Causes no response from the simulator when a quote is requested with a note text of 'rule5'",
              "conditions": {
                "all": [
                  {
                    "fact": "path",
                    "operator": "equal",
                    "value": "/quoterequests"
                  },
                  {
                    "fact": "method",
                    "operator": "equal",
                    "value": "POST"
                  },
                  {
                    "fact": "body",
                    "operator": "equal",
                    "value": "rule5",
                    "path": ".note"
                  }
                ]
              },
              "event": {
                "type": "simulateNoResponse",
                "params": {
                  "noResponse": true
                }
              }
            },
            {
              "ruleId": 6,
              "description": "Causes no response from the simulator when a transfer is made with an ID of 00000000-0000-1000-a000-000000000001",
              "conditions": {
                "all": [
                  {
                    "fact": "path",
                    "operator": "equal",
                    "value": "/transfers"
                  },
                  {
                    "fact": "method",
                    "operator": "equal",
                    "value": "POST"
                  },
                  {
                    "fact": "body",
                    "operator": "equal",
                    "value": "00000000-0000-1000-a000-000000000001",
                    "path": ".transferId"
                  }
                ]
              },
              "event": {
                "type": "simulateNoResponse",
                "params": {
                  "noResponse": true
                }
              }
            },
            {
              "ruleId": 7,
              "description": "Triggers a payee account limit exceeded error response when a transfer is made with an ID of 00000000-0000-1000-a000-000000000002",
              "conditions": {
                "all": [
                  {
                    "fact": "path",
                    "operator": "equal",
                    "value": "/transfers"
                  },
                  {
                    "fact": "method",
                    "operator": "equal",
                    "value": "POST"
                  },
                  {
                    "fact": "body",
                    "operator": "equal",
                    "value": "00000000-0000-1000-a000-000000000002",
                    "path": ".transferId"
                  }
                ]
              },
              "event": {
                "type": "simulateError",
                "params": {
                  "statusCode": 500,
                  "body": {
                    "statusCode": "5200",
                    "message": "Payee limit error"
                  }
                }
              }
            },
            {
              "ruleId": 8,
              "description": "Causes no response from the simulator when a transfer is made with an transfer when the value is 5678 in any currency",
              "conditions": {
                "all": [
                  {
                    "fact": "path",
                    "operator": "equal",
                    "value": "/transfers"
                  },
                  {
                    "fact": "method",
                    "operator": "equal",
                    "value": "POST"
                  },
                  {
                    "fact": "body",
                    "operator": "equal",
                    "value": "5678",
                    "path": ".amount"
                  }
                ]
              },
              "event": {
                "type": "simulateNoResponse",
                "params": {
                  "noResponse": true
                }
              }
            },
            {
              "ruleId": 9,
              "description": "Triggers a payee account limit exceeded error response when a transfer amount is 7890",
              "conditions": {
                "all": [
                  {
                    "fact": "path",
                    "operator": "equal",
                    "value": "/transfers"
                  },
                  {
                    "fact": "method",
                    "operator": "equal",
                    "value": "POST"
                  },
                  {
                    "fact": "body",
                    "operator": "equal",
                    "value": "7890",
                    "path": ".amount"
                  }
                ]
              },
              "event": {
                "type": "simulateError",
                "params": {
                  "statusCode": 500,
                  "body": {
                    "statusCode": "5200",
                    "message": "Payee limit error"
                  }
                }
              }
            },
            {
              "ruleId": 10,
              "description": "Triggers a payee rejected error response when note is payeerejected",
              "conditions": {
                "all": [
                  {
                    "fact": "path",
                    "operator": "equal",
                    "value": "/quoterequests"
                  },
                  {
                    "fact": "method",
                    "operator": "equal",
                    "value": "POST"
                  },
                  {
                    "fact": "body",
                    "operator": "equal",
                    "value": "payeerejected",
                    "path": ".note"
                  }
                ]
              },
              "event": {
                "type": "simulateError",
                "params": {
                  "statusCode": 500,
                  "body": {
                    "statusCode": "5101",
                    "message": "Payee Rejected Quote"
                  }
                }
              }
            }
          ]

