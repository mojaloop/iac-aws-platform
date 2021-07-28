resource "vault_generic_secret" "sim_onboarding_data" {
  for_each = toset(var.simulator_names)
  path      = "${data.terraform_remote_state.k8s-base.outputs.sim_onboarding_secret_name}/${each.value}"
  data_json = jsonencode({
     "client_cert_chain" = "${vault_pki_secret_backend_cert.simulators-personal-client[each.value].private_key}\n${vault_pki_secret_backend_cert.simulators-personal-client[each.value].certificate}\n${vault_pki_secret_backend_root_sign_intermediate.intermediate_simulators[each.value].certificate}\n${data.terraform_remote_state.k8s-base.outputs.ca_cert_cert_pem}"
     "ca_bundle" = vault_pki_secret_backend_cert.simulators-server[each.value].ca_chain
     "host"     = aws_route53_record.simulators-public[each.value].name
     "fqdn"     = aws_route53_record.simulators-public[each.value].fqdn
  })
}
resource "null_resource" "sim-haproxy-wso2-callbacks" {
  
  provisioner "remote-exec" {
    connection {
      host        = data.terraform_remote_state.infrastructure.outputs.haproxy_callback_private_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${var.project_root_path}/terraform/ssh_provisioner_key")
    }
    inline = [   
      "sudo service vault restart",
      "echo result is $?"
    ]

  }
  depends_on = [vault_generic_secret.sim_onboarding_data]
}