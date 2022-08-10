auto_auth = {
  method "kubernetes" {
    mount_path = "auth/${vault_k8sauth_backend}"
    config = {
      role = "${vault_role_name}"
    }
  }

  sink = {
    config = {
        path = "/home/vault/.token"
    }

    type = "file"
  }
}

exit_after_auth = false
pid_file = "/home/vault/.pid"

template {
  contents = "null"
  destination = "/vault/secrets/tmp/null.txt"
  command = "apk add curl jq yq"
}
template {
  contents = "null"
  destination = "/vault/secrets/tmp/null2.txt"
  command = "curl -L -o /tmp/kubectl https://dl.k8s.io/release/v${k8s_version}/bin/linux/amd64/kubectl"
}
template {
  contents = "null"
  destination = "/vault/secrets/tmp/null3.txt"
  command = "install -o root -g root -m 0755 /tmp/kubectl /usr/local/bin/kubectl"
}

template {
  contents = <<EOH
items:
{{ range secrets "secret/onboarding_sims" }}
{{ with secret (printf "secret/onboarding_sims/%s" .) }}
{{.Data.host | indent 2 }}:
{{ .Data | explodeMap | toYAML | indent 4 }}  
{{ end }}{{ end }}
{{ range secrets "secret/onboarding_fsps" }}
{{ with secret (printf "secret/onboarding_fsps/%s" .) }}
{{.Data.host | indent 2 }}:
{{ .Data | explodeMap | toYAML | indent 4 }}  
{{ end }}{{ end }}
{{ range secrets "secret/onboarding_pm4mls" }}
{{ with secret (printf "secret/onboarding_pm4mls/%s" .) }}
{{.Data.host | indent 2 }}:
{{ .Data | explodeMap | toYAML | indent 4 }}  
{{ end }}{{ end }}
  EOH
  destination = "/vault/secrets/tmp/id-cert-output.txt"
  command     = "/vault/secrets/scripts/postcertgen.sh"
}

template {
  contents = <<EOH
{{- with secret "${vault_pki_name}/issue/${vault_server_role}" "common_name=${haproxy_common_name}" -}}
{{ .Data.private_key }}
{{ .Data.certificate }}
{{ .Data.issuing_ca }}
{{- end }}
  EOH
  destination = "/etc/haproxy/certificates/haproxy-callback.fullchain.crt"
}


template {
  contents = <<EOH
global
    log stdout format raw local0
    maxconn 4096
    tune.ssl.default-dh-param 2048

defaults
    log global
    mode http
    option forwardfor
    option httplog
    option http-server-close
    timeout client 1m
    timeout connect 10s
    timeout server 1m
    default-server init-addr last,libc,none

#userlist dataplane-api
#  user dataplaneapi insecure-password secret

#program dataplane-api
#  command /usr/local/bin/dataplaneapi --host 0.0.0.0 --port 5555 --haproxy-bin /usr/sbin/haproxy --config-file /etc/haproxy/haproxy.cfg --reload-cmd "kill -SIGUSR2 1" --reload-delay 5 --userlist dataplane-api 
#  no option start-on-reload

frontend http-in
    option                  http-keep-alive
    bind *:80
    redirect scheme https code 301 if !{ ssl_fc }
    

frontend https-in
    option                  http-keep-alive
    bind :443 force-tlsv12 ciphers EECDH+CHACHA20:ECDH+AESGCM:DH+AESGCM:EECDH+AES256:DH+AES256:EECDH+AES128:DH+AES:!aNULL:!MD5:!DSS ssl crt /usr/local/etc/ssl/tls_cert.pem
    http-request            set-header X-Forwarded-Proto https
    http-request            set-var(txn.txnhost) hdr(host)
    http-request            set-var(txn.txnpath) path

{{range secrets "secret/onboarding_sims"}}
{{ with secret (printf "secret/onboarding_sims/%s" .) }}
    acl {{.Data.fqdn}}_acl path -i -m beg /sim/{{.Data.host}}/
{{end}}
{{end}}
{{range secrets "secret/onboarding_fsps"}}
{{ with secret (printf "secret/onboarding_fsps/%s" .) }}
    acl {{.Data.fqdn}}_acl path -i -m beg /fsp/{{.Data.host}}/
{{end}}
{{end}}
{{range secrets "secret/onboarding_pm4mls"}}
{{ with secret (printf "secret/onboarding_pm4mls/%s" .) }}
    acl {{.Data.fqdn}}_acl path -i -m beg /fsp/{{.Data.host}}/
{{end}}
{{end}}

{{range secrets "secret/onboarding_sims"}}
{{ with secret (printf "secret/onboarding_sims/%s" .) }}
    use_backend {{.Data.host}} if {{.Data.fqdn}}_acl
{{end}}
{{end}}
{{range secrets "secret/onboarding_fsps"}}
{{ with secret (printf "secret/onboarding_fsps/%s" .) }}
    use_backend {{.Data.host}} if {{.Data.fqdn}}_acl
{{end}}
{{end}}
{{range secrets "secret/onboarding_pm4mls"}}
{{ with secret (printf "secret/onboarding_pm4mls/%s" .) }}
    use_backend {{.Data.host}} if {{.Data.fqdn}}_acl
{{end}}
{{end}}

{{range secrets "secret/onboarding_sims"}}
{{ with secret (printf "secret/onboarding_sims/%s" .) }}
backend {{.Data.host}}
    balance roundrobin
    server {{.Data.host}} {{.Data.fqdn}} ssl crt /vault/secrets/certificates/{{.Data.host}}.client.fullchain.crt ca-file /vault/secrets/certificates/{{.Data.host}}_server_ca.crt verify required
{{end}}
{{end}}
{{range secrets "secret/onboarding_pm4mls"}}
{{ with secret (printf "secret/onboarding_pm4mls/%s" .) }}
backend {{.Data.host}}
    http-request set-path %[path,regsub(^/fsp/{{.Data.host}}/,/)]
    http-request set-header Host {{.Data.fqdn}}
    balance roundrobin
    server {{.Data.host}} {{.Data.fqdn}} {{if .Data.mtls_disabled}}{{else}}ssl sni str({{.Data.fqdn}}) crt /etc/haproxy/certificates/{{.Data.host}}.client.fullchain.crt ca-file /etc/haproxy/certificates/{{.Data.host}}_server_ca.crt verify none{{end}}
{{end}}
{{end}}
{{range secrets "secret/onboarding_fsps"}}
{{ with secret (printf "secret/onboarding_fsps/%s" .) }}
backend {{.Data.host}}
    http-request set-path %[path,regsub(^/fsp/{{.Data.host}}/,/)]
    http-request set-header Host {{.Data.fqdn}}
    balance roundrobin
    server {{.Data.host}} {{.Data.fqdn}} {{if .Data.mtls_disabled}}{{else}}ssl sni str({{.Data.fqdn}}) crt /etc/haproxy/certificates/{{.Data.host}}.client.fullchain.crt ca-file /etc/haproxy/certificates/{{.Data.host}}_server_ca.crt verify none{{end}}
{{- end -}}
{{- end -}}
  EOH
  destination = "/etc/haproxy/haproxy.cfg"
  command     = "/vault/secrets/scripts/restarthaproxy.sh"      
}

template {
  contents = <<EOH
data:
  whitelist-source-range: {{ with secret "secret/whitelist_vpn" }}{{ range $k, $v := .Data }}{{ $v }},{{ end }}{{ end }}{{ with secret "secret/whitelist_fsps" }}{{ range $k, $v := .Data }}{{ $v }},{{ end }}{{ end }}{{ with secret "secret/whitelist_pm4mls" }}{{ range $k, $v := .Data }}{{ $v }},{{ end }}{{ end }}10.25.0.0/16
  EOH
  destination = "/vault/secrets/tmp/whitelist.yaml"
  command     = "/vault/secrets/scripts/updatecm.sh"
}

vault = {
  address = "http://vault.default.svc.cluster.local:8200"
}