[Unit]
Description = "Starts confd"
After = network.target

[Service]
ExecStart = /usr/bin/confd --backend vault -interval 60 --auth-type token --auth-token ${vault_token} --node ${vault_addr} -prefix='/secret'

[Install]
WantedBy = multi-user.target
