/etc/vault/scripts/genfilesfromyaml.sh ca_bundle _server_ca.crt /etc/haproxy/certificates/ /tmp/id-cert-output.txt
/etc/vault/scripts/genfilesfromyaml.sh client_cert_chain .client.fullchain.crt /etc/haproxy/certificates/ /tmp/id-cert-output.txt
systemctl restart haproxy