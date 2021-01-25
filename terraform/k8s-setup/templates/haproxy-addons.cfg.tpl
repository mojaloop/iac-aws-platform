global
  daemon
  log 127.0.0.1 local0
  log 127.0.0.1 local1 notice
  maxconn 4096
  tune.ssl.default-dh-param 2048

defaults
    mode    http
    option forwardfor
    option http-server-close

frontend http-in
    bind *:80
    mode http
    redirect scheme https code 301 if !{ ssl_fc }
    timeout client 1m

frontend http-prom
    bind *:30001
    mode http
    default_backend nginx-ingress
    timeout client 1m
    http-request set-header Host                        ${prom}

frontend http-20000
    bind *:20000
    mode http
    default_backend nginx-ingress
    timeout client 1m
    acl whitelist_mcm src -f /etc/haproxy/whitelist_mcm
    http-request deny if !whitelist_mcm
    http-request set-header Host                        ${pm4ml}

frontend http-30000
    bind *:30000
    mode http
    default_backend nginx-ingress
    timeout client 1m
    acl whitelist_mcm src -f /etc/haproxy/whitelist_mcm
    http-request deny if !whitelist_mcm
    http-request set-header Host                        ${mcm}

frontend k8s-ingress
    http-request set-header X-SSL                       %%{+Q}[ssl_fc]
    http-request set-header X-SSL-Client-Verify         %%{+Q}[ssl_c_verify]
    http-request set-header X-SSL-Client-SHA1           %%{+Q}[ssl_c_sha1]
    http-request set-header X-SSL-Client-DN             %%{+Q}[ssl_c_s_dn]
    http-request set-header X-SSL-Client-CN             %%{+Q}[ssl_c_s_dn(cn)]
    http-request set-header X-SSL-Issuer                %%{+Q}[ssl_c_i_dn]
    http-request set-header X-SSL-Client-Not-Before     %%{+Q}[ssl_c_notbefore]
    http-request set-header X-SSL-Client-Serial         %%{+Q}[ssl_c_serial,hex]
    http-request set-header X-SSL-Client-Version        %%{+Q}[ssl_c_version]
    http-request set-header X-Forwarded-Proto https
    http-request set-header X-Forwarded-For             %[src]

    bind :443 force-tlsv12 ciphers EECDH+CHACHA20:ECDH+AESGCM:DH+AESGCM:EECDH+AES256:DH+AES256:EECDH+AES128:DH+AES:!aNULL:!MD5:!DSS ssl crt-list /etc/haproxy/ssl_sims.lst verify required ca-file /etc/haproxy/certificates/ca_bundle.crt
    acl whitelist src -f /etc/haproxy/whitelist
    http-request deny if !whitelist

    mode http
     default_backend nginx-ingress
     timeout client 1m

backend nginx-ingress
    mode http
    balance roundrobin
%{ for host in keys(workernodes) ~}
     server ${workernodes[host]} ${host}:30001;
%{ endfor ~}
    timeout connect        10s
    timeout server          1m
