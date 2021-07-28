[Unit]
Description = "Starts Vault"

[Service]
ExecStart = /usr/bin/vault agent -config=${vault_config}

[Install]
WantedBy = multi-user.target
