resource "local_file" "gp_postman_pm4ml_certlist_file" {
  content = templatefile("${path.module}/templates/test_cert_list.json.tpl", {
    LAB_DOMAIN                     = trimsuffix(data.terraform_remote_state.infrastructure.outputs.public_subdomain, "."),
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
}