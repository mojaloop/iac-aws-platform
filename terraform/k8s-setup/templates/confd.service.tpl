[Unit]
Description = "Starts confd"
After = network.target
StartLimitInterval = 300
StartLimitBurst = 50

[Service]
ExecStart = /usr/bin/confd --backend vault -interval 60 --auth-type token --auth-token ${vault_token} --node ${vault_addr} -prefix='/secret'
Restart = on-failure
RestartSec = 5

[Install]
WantedBy = multi-user.target
