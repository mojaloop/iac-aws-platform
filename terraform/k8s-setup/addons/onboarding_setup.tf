resource "local_file" "gp_postman_pm4ml_certlist_file" {
  content = templatefile("${path.module}/templates/test_cert_list.json.tpl", {
    LAB_DOMAIN                     = trimsuffix(data.terraform_remote_state.infrastructure.outputs.public_subdomain, "."),
    PAYERFSP_KEY_FILENAME          = "../secrets_chart/payerfsp/tls/payerfsp_client.key",
    PAYEEFSP_KEY_FILENAME          = "../secrets_chart/payeefsp/tls/payeefsp_client.key",
    TESTFSP1_KEY_FILENAME          = "../secrets_chart/testfsp1/tls/testfsp1_client.key",
    TESTFSP2_KEY_FILENAME          = "../secrets_chart/testfsp2/tls/testfsp2_client.key",
    TESTFSP3_KEY_FILENAME          = "../secrets_chart/testfsp3/tls/testfsp3_client.key",
    TESTFSP4_KEY_FILENAME          = "../secrets_chart/testfsp4/tls/testfsp4_client.key",
    PAYERFSP_CERT_FILENAME         = "../secrets_chart/payerfsp/tls/payerfsp_client.crt",
    PAYEEFSP_CERT_FILENAME         = "../secrets_chart/payeefsp/tls/payeefsp_client.crt",
    TESTFSP1_CERT_FILENAME         = "../secrets_chart/testfsp1/tls/testfsp1_client.crt",
    TESTFSP2_CERT_FILENAME         = "../secrets_chart/testfsp2/tls/testfsp2_client.crt",
    TESTFSP3_CERT_FILENAME         = "../secrets_chart/testfsp3/tls/testfsp3_client.crt",
    TESTFSP4_CERT_FILENAME         = "../secrets_chart/testfsp4/tls/testfsp4_client.crt",
    PM4ML_DOMAIN                = "${replace(var.client, "-", "")}${replace(var.environment, "-", "")}k3s.${data.terraform_remote_state.infrastructure.outputs.public_subdomain}",
    DFSP1_KEY_FILENAME          = "../secrets_chart/pm4mlsenderfsp/tls/pm4mlsenderfsp_client.key",
    DFSP2_KEY_FILENAME          = "../secrets_chart/pm4mlreceiverfsp/tls/pm4mlreceiverfsp_client.key",
    DEMOWALLET_KEY_FILENAME     = "../secrets_chart/demowallet/tls/demowallet_client.key",
    DEMOMFI_KEY_FILENAME        = "../secrets_chart/demomfi/tls/demomfi_client.key",
    DFSP1_CERT_FILENAME         = "../secrets_chart/pm4mlsenderfsp/tls/pm4mlsenderfsp_client.crt",
    DFSP2_CERT_FILENAME         = "../secrets_chart/pm4mlreceiverfsp/tls/pm4mlreceiverfsp_client.crt",
    DEMOWALLET_CERT_FILENAME    = "../secrets_chart/demowallet/tls/demowallet_client.crt",
    DEMOMFI_CERT_FILENAME       = "../secrets_chart/demomfi/tls/demomfi_client.crt"
  })
  filename   = "${path.root}/sim_tests/test_cert_list.json"
  depends_on = [module.provision_sims_to_wso2, module.provision_accounts_to_wso2]
}

resource "local_file" "gp_postman_environment_file" {
  content = templatefile("${path.module}/templates/Lab.postman_environment.json.tpl", {
    LAB_DOMAIN                         = trimsuffix(data.terraform_remote_state.infrastructure.outputs.public_subdomain, "."),
    CURRENCY_CODE                      = var.hub_currency_code,
    HUB_OPERATOR_CONSUMER_KEY          = module.provision_accounts_to_wso2.client-ids["hub_operator"],
    HUB_OPERATOR_CONSUMER_SECRET       = module.provision_accounts_to_wso2.client-secrets["hub_operator"],
    NORESPONSEPAYEEFSP_CONSUMER_KEY    = module.provision_accounts_to_wso2.client-ids["noresponsepayeefsp"],
    NORESPONSEPAYEEFSP_CONSUMER_SECRET = module.provision_accounts_to_wso2.client-secrets["noresponsepayeefsp"],
    PAYERFSP_CONSUMER_KEY              = module.provision_sims_to_wso2.client-ids["payerfsp"],
    PAYEEFSP_CONSUMER_KEY              = module.provision_sims_to_wso2.client-ids["payeefsp"],
    TESTFSP1_CONSUMER_KEY              = module.provision_sims_to_wso2.client-ids["testfsp1"],
    TESTFSP2_CONSUMER_KEY              = module.provision_sims_to_wso2.client-ids["testfsp2"],
    TESTFSP3_CONSUMER_KEY              = module.provision_sims_to_wso2.client-ids["testfsp3"],
    TESTFSP4_CONSUMER_KEY              = module.provision_sims_to_wso2.client-ids["testfsp4"],
    PAYERFSP_CONSUMER_SECRET           = module.provision_sims_to_wso2.client-secrets["payerfsp"],
    PAYEEFSP_CONSUMER_SECRET           = module.provision_sims_to_wso2.client-secrets["payeefsp"],
    TESTFSP1_CONSUMER_SECRET           = module.provision_sims_to_wso2.client-secrets["testfsp1"],
    TESTFSP2_CONSUMER_SECRET           = module.provision_sims_to_wso2.client-secrets["testfsp2"],
    TESTFSP3_CONSUMER_SECRET           = module.provision_sims_to_wso2.client-secrets["testfsp3"],
    TESTFSP4_CONSUMER_SECRET           = module.provision_sims_to_wso2.client-secrets["testfsp4"],
    payerfspJWSKey                     = replace(tls_private_key.simulators["payerfsp"].private_key_pem, "\n", "\\n"),
    payeefspJWSKey                     = replace(tls_private_key.simulators["payeefsp"].private_key_pem, "\n", "\\n"),
    testfsp1JWSKey                     = replace(tls_private_key.simulators["testfsp1"].private_key_pem, "\n", "\\n"),
    testfsp2JWSKey                     = replace(tls_private_key.simulators["testfsp2"].private_key_pem, "\n", "\\n"),
    testfsp3JWSKey                     = replace(tls_private_key.simulators["testfsp3"].private_key_pem, "\n", "\\n"),
    testfsp4JWSKey                     = replace(tls_private_key.simulators["testfsp4"].private_key_pem, "\n", "\\n"),
    MERCHANT_ORACLE_ENDPOINT           = "http://moja-simulator.${trimsuffix(data.terraform_remote_state.infrastructure.outputs.public_subdomain, ".")}.internal:30000/oracle",
    ALIAS_ORACLE_ENDPOINT              = "http://${data.terraform_remote_state.k8s-base.outputs.alias-oracle-fqdn}:30000/als-api",
    ALIAS_ORACLE_ADMIN_API_ENDPOINT    = "http://${data.terraform_remote_state.k8s-base.outputs.alias-oracle-fqdn}:30000/admin-api",
    ACCOUNT_ORACLE_ENDPOINT            = "http://${data.terraform_remote_state.k8s-base.outputs.mfi-account-oracle-fqdn}:30000/als-api",
    ACCOUNT_ORACLE_ADMIN_API_ENDPOINT  = "http://${data.terraform_remote_state.k8s-base.outputs.mfi-account-oracle-fqdn}:30000/admin-api",
    PM4ML_DOMAIN                       = "${replace(var.client, "-", "")}${replace(var.environment, "-", "")}k3s.${data.terraform_remote_state.infrastructure.outputs.public_subdomain}"
  })
  filename   = "${path.root}/sim_tests/Lab.postman_environment.json"
  depends_on = [module.provision_sims_to_wso2, module.provision_accounts_to_wso2]
}