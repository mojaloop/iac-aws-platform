simulators:
  ${name}:
    ingress:
      enabled: "${INGRESS_ENABLED}"
      hosts: ["${INGRESS_HOST}"]
    config:
      backend:
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
        env:
          FEE_MULTIPLIER: "0.00"
