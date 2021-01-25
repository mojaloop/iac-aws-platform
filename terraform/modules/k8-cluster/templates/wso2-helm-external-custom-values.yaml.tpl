wso2-am-allinone-ext:
  dependencyConfigProps:
    API_GW_HOST:
      name: "API_GW_HOST"
      propValue: "${ext-gw-alias}"
      releasePrefixValue: false
    API_STORE_HOST:
      name: "API_STORE_HOST"
      propValue: "${ext-gw-alias}"
      releasePrefixValue: false
    API_PUB_HOST:
      name: "API_PUB_HOST"
      propValue: "${ext-gw-alias}"
      releasePrefixValue: false
    WSO2_DB_HOST:
      name: "WSO2_DB_HOST"
      propValue: "${wso2-mysql-host}"
      releasePrefixValue: false
    WSO2_DB_PORT:
      name: "WSO2_DB_PORT"
      propValue: ${wso2-mysql-port}
      releasePrefixValue: false
    WSO2_DB_USER:
      name: "WSO2_DB_USER"
      propValue: "${wso2-mysql-user}"
      releasePrefixValue: false
    WSO2_DB_PW:
      name: "WSO2_DB_PW"
      propValue: "${wso2-mysql-password}"
      releasePrefixValue: false
    ISKM_HOST:
      name: "ISKM_HOST"
      propValue: "${iskm-alias}"
      releasePrefixValue: false
    KEYSTORE_PASSWORD:
      name: "KEYSTORE_PASSWORD"
      propValue: "${wso2-keystore-password}"
      releasePrefixValue: false
