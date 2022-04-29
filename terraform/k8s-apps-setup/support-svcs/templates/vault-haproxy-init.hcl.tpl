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

exit_after_auth = true
pid_file = "/home/vault/.pid"

template = {
  contents = <<EOH
#!/bin/ash
if pgrep haproxy; then
    echo "found haproxy"
    kill -SIGUSR2 $(pgrep haproxy | head -1)
else
    echo "haproxy not running"
fi
  EOH
  destination = "/vault/secrets/scripts/restarthaproxy.sh"
}

template = {
  contents = <<EOH
#!/bin/ash
OUTPUT_VAR=$1
FILE_EXT=$2
CERT_PATH=$3
INPUT_FILE=$4
yq -M e '.items | keys' $INPUT_FILE | sed 's/^- //g' | while IFS= read -r line; do
  FILTER="e '.items[\"$line\"]."$OUTPUT_VAR"'"
  eval "yq" $FILTER $INPUT_FILE > "$CERT_PATH/$${line}$FILE_EXT"
done
  EOH
  destination = "/vault/secrets/scripts/genfilesfromyaml.sh"
}

template = {
  contents = <<EOH
#!/bin/ash
kubectl patch configmap/nginx-ext-ingress-nginx-controller \
  -n nginx-ext \
  --type merge \
  --patch "$(cat /vault/secrets/tmp/whitelist.yaml)"
  EOH
  destination = "/vault/secrets/scripts/updatecm.sh"
}
template = {
  contents = <<EOH
#!/bin/ash
mkdir -p /etc/haproxy/certificates
/vault/secrets/scripts/genfilesfromyaml.sh ca_bundle _server_ca.crt /etc/haproxy/certificates/ /vault/secrets/tmp/id-cert-output.txt
/vault/secrets/scripts/genfilesfromyaml.sh client_cert_chain .client.fullchain.crt /etc/haproxy/certificates/ /vault/secrets/tmp/id-cert-output.txt
/vault/secrets/scripts/restarthaproxy.sh
  EOH
  destination = "/vault/secrets/scripts/postcertgen.sh"
  command = "chmod +x /vault/secrets/scripts/genfilesfromyaml.sh /vault/secrets/scripts/postcertgen.sh /vault/secrets/scripts/restarthaproxy.sh /vault/secrets/scripts/updatecm.sh"
}


vault = {
  address = "http://vault.default.svc.cluster.local:8200"
}