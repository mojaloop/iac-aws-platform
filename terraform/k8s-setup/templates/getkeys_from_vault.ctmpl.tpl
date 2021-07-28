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