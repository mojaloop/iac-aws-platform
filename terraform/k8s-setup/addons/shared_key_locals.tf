locals {
  switch_pem = tomap({
                  "switch.pem" = data.terraform_remote_state.k8s-base.outputs.switch_jws_key
                })
  non_resp   = tomap({
                  "noresponsepayeefsp.pem" = tls_private_key.simulators["payeefsp"].public_key_pem
                })
  jws_pub    = merge(local.switch_pem, local.non_resp, local.sim_pem)
}