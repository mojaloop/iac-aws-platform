 {
    "id": "0e6e184d-85c5-4a4a-b2fb-f7a1360b2a62",
    "name": "Onboard-Generic-FSP",
    "values": [
        {
            "key": "HOST_CENTRAL_LEDGER",
            "value": "https://${extgw_host}:8243",
            "enabled": true
        },
        {
            "key": "BASE_CENTRAL_LEDGER_ADMIN",
            "value": "/admin/1.0",
            "enabled": true
        },
        {
            "key": "DFSP_NAME",
            "value": "${sim_name}",
            "enabled": true
        },
        {
            "key": "HUB_NAME",
            "value": "Hub",
            "enabled": true
        },
        {
            "key": "HUB_OPERATOR",
            "value": "hub_operator",
            "enabled": true
        },
        {
            "key": "DFSP_CURRENCY",
            "value": "${sim_currency}",
            "enabled": true
        },
        {
            "key": "INITIAL_NET_DEBIT_CAP",
            "value": "5000",
            "enabled": true
        },
        {
            "key": "INITIAL_POSITION",
            "value": "0",
            "enabled": true
        },
        {
            "key": "GENERIC_DFSP_CALLBACK_URL",
            "value": "http://${intgw_host}:8844/${sim_name}/1.0",
            "enabled": true
        },
        {
            "key": "NDC_THRESHOLD_BREACH_EMAIL",
            "value": "iac-test-users@example.com",
            "enabled": true
        },
        {
            "key": "NDC_ADJUSTMENT_EMAIL",
            "value": "iac-test-users@example.com",
            "enabled": true
        },
        {
            "key": "SETTLEMENT_TRANSFER_POSITION_CHANGE_EMAIL",
            "value": "iac-test-users@example.com",
            "enabled": true
        }
    ],
    "_postman_variable_scope": "environment",
    "_postman_exported_at": "2020-04-28T08:22:18.685Z",
    "_postman_exported_using": "Postman/7.23.0"
}