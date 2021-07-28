
locals {
  switch_pem = map("switch.pem", data.terraform_remote_state.k8s-base.outputs.switch_jws_key)
  non_resp   = map("noresponsepayeefsp.pem", tls_private_key.simulators["payeefsp"].public_key_pem)
  sim_pem    = { for value in toset(var.simulator_names) : "${value}.pem" => tls_private_key.simulators[value].public_key_pem }
  jws_pub    = merge(local.switch_pem, local.non_resp, local.sim_pem)
}