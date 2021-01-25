resource "local_file" "root_ca_switch_certificate" {
  content         = "${data.terraform_remote_state.k8s-base.outputs.root_signed_intermediate_certificate}\n${data.terraform_remote_state.k8s-base.outputs.ca_cert_cert_pem}"
  filename        = "${path.root}/secrets_chart/switch_ca/ca_cert.pem"
  file_permission = "0644"
}

resource "local_file" "simulators_server_certificate" {
  for_each        = toset(var.simulator_names)
  content         = vault_pki_secret_backend_cert.simulators-server[each.value].certificate
  filename        = "${path.root}/secrets_chart/${each.value}/tls/${each.value}_server.crt"
  file_permission = "0644"
}

resource "local_file" "simulators_server_key" {
  for_each          = toset(var.simulator_names)
  sensitive_content = vault_pki_secret_backend_cert.simulators-server[each.value].private_key
  filename          = "${path.root}/secrets_chart/${each.value}/tls/${each.value}_server.key"
  file_permission   = "0644"
}

resource "local_file" "root_ca_switch_certificate_simulators" {
  for_each        = toset(var.simulator_names)
  content         = "${data.terraform_remote_state.k8s-base.outputs.root_signed_intermediate_certificate}\n${data.terraform_remote_state.k8s-base.outputs.ca_cert_cert_pem}"
  filename        = "${path.root}/secrets_chart/${each.value}/tls/switch_server_ca.pem"
  file_permission = "0644"
}

resource "local_file" "simulators_personal_client_certificate" {
  for_each        = toset(var.simulator_names)
  content         = vault_pki_secret_backend_cert.simulators-personal-client[each.value].certificate
  filename        = "${path.root}/secrets_chart/${each.value}/tls/${each.value}_client.crt"
  file_permission = "0644"
}

resource "local_file" "switch_simulators_client_certificate" {
  for_each        = toset(var.simulator_names)
  content         = vault_pki_secret_backend_cert.switch-simulators-client[each.value].certificate
  filename        = "${path.root}/secrets_chart/${each.value}/tls/${each.value}_switch_client.crt"
  file_permission = "0644"
}

resource "local_file" "simulators_personal_client_key" {
  for_each          = toset(var.simulator_names)
  sensitive_content = vault_pki_secret_backend_cert.simulators-personal-client[each.value].private_key
  filename          = "${path.root}/secrets_chart/${each.value}/tls/${each.value}_client.key"
  file_permission   = "0644"
}

resource "local_file" "switch_simulators_client_key" {
  for_each          = toset(var.simulator_names)
  sensitive_content = vault_pki_secret_backend_cert.switch-simulators-client[each.value].private_key
  filename          = "${path.root}/secrets_chart/${each.value}/tls/${each.value}_switch_client.key"
  file_permission   = "0644"
}

resource "local_file" "simulators_server_ca" {
  for_each        = toset(var.simulator_names)
  content         = "${vault_pki_secret_backend_root_sign_intermediate.intermediate_simulators[each.value].certificate}\n${data.terraform_remote_state.k8s-base.outputs.ca_cert_cert_pem}"
  filename        = "${path.root}/secrets_chart/${each.value}/tls/${each.value}_server_ca.pem"
  file_permission = "0644"
}

resource "local_file" "simulators_client_ca" {
  for_each        = toset(var.simulator_names)
  content         = "${data.terraform_remote_state.k8s-base.outputs.root_signed_intermediate_certificate}\n${data.terraform_remote_state.k8s-base.outputs.ca_cert_cert_pem}"
  filename        = "${path.root}/secrets_chart/${each.value}/tls/${each.value}_client_ca.pem"
  file_permission = "0644"
}


#########################################################
#       SIM JWS PUBLIC & PRIVATE KEYS
#########################################################


resource "local_file" "jws_public_keys_simulators_simulators" {
  for_each        = toset(var.simulator_names)
  content         = tls_private_key.simulators[each.value].public_key_pem
  filename        = "${path.root}/secrets_chart/${each.value}/jwsVerificationCerts/${each.value}.pem"
  file_permission = "0644"
}

resource "local_file" "jws_private_key_simulators" {
  for_each          = toset(var.simulator_names)
  sensitive_content = tls_private_key.simulators[each.value].private_key_pem
  filename          = "${path.root}/secrets_chart/${each.value}/jwsSigningKey/private.key"
  file_permission   = "0644"
}
