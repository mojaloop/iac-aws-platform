locals {
  switch_pem = tomap({
                  "switch.pem" = data.terraform_remote_state.k8s-base.outputs.switch_jws_key
                })

  jws_pub    = local.switch_pem
}