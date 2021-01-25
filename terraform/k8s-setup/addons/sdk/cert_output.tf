resource "local_file" "server_certificate" {
  content         = vault_pki_secret_backend_cert.server.certificate
  filename        = "${path.root}/certs/${var.name}/tls/${var.name}_server.crt"
  file_permission = "0644"
}

resource "local_file" "server_key" {
  sensitive_content = vault_pki_secret_backend_cert.server.private_key
  filename          = "${path.root}/certs/${var.name}/tls/${var.name}_server.key"
  file_permission   = "0644"
}

resource "local_file" "personal_client_certificate" {
  content         = vault_pki_secret_backend_cert.personal_client.certificate
  filename        = "${path.root}/certs/${var.name}/tls/${var.name}_client.crt"
  file_permission = "0644"
}

resource "local_file" "switch_client_certificate" {
  content         = vault_pki_secret_backend_cert.switch_client.certificate
  filename        = "${path.root}/certs/${var.name}/tls/${var.name}_switch_client.crt"
  file_permission = "0644"
}

resource "local_file" "personal_client_key" {
  sensitive_content = vault_pki_secret_backend_cert.personal_client.private_key
  filename          = "${path.root}/certs/${var.name}/tls/${var.name}_client.key"
  file_permission   = "0644"
}

resource "local_file" "switch_client_key" {
  sensitive_content = vault_pki_secret_backend_cert.switch_client.private_key
  filename          = "${path.root}/certs/${var.name}/tls/${var.name}_switch_client.key"
  file_permission   = "0644"
}

resource "local_file" "server_ca" {
  content         = "${vault_pki_secret_backend_root_sign_intermediate.intermediate.certificate}\n${var.ca_cert_cert_pem}"
  filename        = "${path.root}/certs/${var.name}/tls/${var.name}_server_ca.pem"
  file_permission = "0644"
}

resource "local_file" "client_ca" {
  content         = "${var.root_signed_intermediate_certificate}\n${var.ca_cert_cert_pem}"
  filename        = "${path.root}/certs/${var.name}/tls/${var.name}_client_ca.pem"
  file_permission = "0644"
}

#########################################################
#       SIM JWS PUBLIC & PRIVATE KEYS
#########################################################

# TODO: move to addons module and do this there
# resource "local_file" "generate_onboarding_json" {
#   content = jsonencode([for obj in local.data :
#     {
#       "DFSP_NAME"               = obj.name,
#       "DFSP_CURRENCY"           = obj.currency,
#       "DFSP_MSISDN"             = obj.msisdn,
#       "DFSP_BUSINESS_ID"        = obj.business_id,
#       "DFSP_NOTIFICATION_EMAIL" = obj.notification_email,
#       "DFSP_ACCOUNT_ID"         = obj.account_id,
#       "BACKEND_TEST_API_URL"    = "http://${obj.sim_endpoint}"
#     }
#   ])
#   filename        = "${path.root}/sim_tests/json_data.json"
#   file_permission = "0644"
# }
