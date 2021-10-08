resource "vault_generic_secret" "sim_onboarding_data" {
  for_each = toset(var.simulator_names)
  path      = "${data.terraform_remote_state.k8s-base.outputs.sim_onboarding_secret_name}/${each.value}"
  disable_read = false
  data_json = jsonencode({
     "client_cert_chain" = "${data.local_file.sim_client_key[each.value].content}\n${data.local_file.sim_client_cert[each.value].content}"
     "ca_bundle" = data.local_file.sim_ca[each.value].content
     "host"     = each.key
     "fqdn"     = "connector.${each.value}.${replace(var.client, "-", "")}${replace(var.environment, "-", "")}k3s.${data.terraform_remote_state.infrastructure.outputs.public_subdomain}"
  })
}

data "local_file" "sim_client_cert" {
  for_each = toset(var.simulator_names)
  filename = "${path.module}/sim-certoutput/${each.value}-client-cert.pem"
}
data "local_file" "sim_client_key" {
  for_each = toset(var.simulator_names)
  filename = "${path.module}/sim-certoutput/${each.value}-client-key.pem"
}
data "local_file" "sim_ca" {
  for_each = toset(var.simulator_names)
  filename = "${path.module}/sim-certoutput/${each.value}-ca-cert.pem"
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