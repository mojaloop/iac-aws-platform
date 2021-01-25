variable "name" {
  description = "Unique string naming the SDK"
  type        = string
}

variable "haproxy_callback_ip" {
  description = "ip for callback haproxy"
}

variable "public_subdomain" {
  description = "subdomain for hosts"
}

variable "jws_pub_key_data" {
  description = "JWS public keys for all 'end user' components"
  type        = map
}

variable "ca_cert_cert_pem" {}

variable "vault_root_path" {}

variable "root_signed_intermediate_certificate" {}

variable "project_root_path" {}

variable "haproxy_callback_private_ip" {}

variable "private_subdomain" {}

variable "intgw_fqdn" {}

variable "extgw_fqdn" {}

variable "helm_mojaloop_version" {
  description = "Version of Mojaloop being installed"
  type        = string
}
