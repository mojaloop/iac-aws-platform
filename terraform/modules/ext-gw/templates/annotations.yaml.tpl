annotations:
  vault.hashicorp.com/agent-inject: "true"
  vault.hashicorp.com/role: "${vault_role_name}"
  vault.hashicorp.com/agent-inject-secret-${vault_secret_file_name}: "${vault_secret_name}"
  vault.hashicorp.com/agent-inject-template-${vault_secret_file_name}: |
          {{- with secret "${vault_secret_name}" -}}
          <?xml version="1.0" encoding="UTF-8"?>
          <config>
            {{ range $k, $v := .Data }}
            <dfsp>
                <name>{{ $k }}</name>
                <cidrs>{{ $v }}</cidrs>
            </dfsp>{{- end -}}
          </config>
          {{- end -}}