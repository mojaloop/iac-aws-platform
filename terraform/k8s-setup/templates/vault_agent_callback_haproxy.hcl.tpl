pid_file = "./pidfile"

vault {
        address = "${vault_address}"
        tls_skip_verify = "true"
}

auto_auth {
        method "approle" {
                mount_path = "auth/approle"
                config = {
                        role_id_file_path = "${role_id_file_path}"
                        secret_id_file_path = "${secret_id_file_path}"
                        remove_secret_id_file_after_reading = "false"
                }
        }
}

template {
  source      = "${keytemplate_file_path}"
  destination = "/tmp/id-cert-output.txt"
  command     = "sudo /etc/vault/scripts/postcertgen.sh"
}
template {
  source      = "${haproxy_template_file_path}"
  destination = "/tmp/haproxy.cfg"
  command     = "sudo /etc/vault/scripts/posthaproxygen.sh"      
}
