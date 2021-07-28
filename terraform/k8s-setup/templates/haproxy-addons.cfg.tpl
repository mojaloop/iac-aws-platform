global
    log 127.0.0.1:514  local0  info
    chroot /var/lib/haproxy
    stats socket /run/haproxy/admin.sock mode 660 level admin
    stats timeout 30s
    user haproxy
    group haproxy
    daemon
    maxconn 4096
    tune.ssl.default-dh-param 2048

defaults
    log global
    mode http
    option forwardfor
    option httplog
    option http-server-close
    timeout client 1m
    timeout connect        10s
    timeout server          1m

frontend http-in
    bind *:80
    redirect scheme https code 301 if !{ ssl_fc }

frontend http-prom
    bind *:30001
    default_backend nginx-ingress
    http-request set-header Host                        ${prom}


frontend k8s-ingress
    http-request set-header X-SSL                       %%{+Q}[ssl_fc]
    http-request set-header X-SSL-Client-Verify         %%{+Q}[ssl_c_verify]
    http-request set-header X-SSL-Client-SHA1           %%{+Q}[ssl_c_sha1,hex]
    http-request set-header X-SSL-Client-DN             %%{+Q}[ssl_c_s_dn]
    http-request set-header X-SSL-Client-CN             %%{+Q}[ssl_c_s_dn(cn)]
    http-request set-header X-SSL-Issuer                %%{+Q}[ssl_c_i_dn]
    http-request set-header X-SSL-Client-Not-Before     %%{+Q}[ssl_c_notbefore]
    http-request set-header X-SSL-Client-Serial         %%{+Q}[ssl_c_serial,hex]
    http-request set-header X-SSL-Client-Version        %%{+Q}[ssl_c_version]
    http-request set-header X-Forwarded-Proto https
    http-request set-header X-Forwarded-For             %[src]
    http-request set-header Host                        %%{+Q}[ssl_c_s_dn(cn)]

    bind :443 force-tlsv12 ciphers EECDH+CHACHA20:ECDH+AESGCM:DH+AESGCM:EECDH+AES256:DH+AES256:EECDH+AES128:DH+AES:!aNULL:!MD5:!DSS ssl crt-list /etc/haproxy/ssl_sims.lst verify required ca-file /etc/haproxy/certificates/ca_bundle.crt
    acl whitelist src -f /etc/haproxy/whitelist
    http-request deny if !whitelist

    default_backend nginx-ingress

backend nginx-ingress
    balance roundrobin
%{ for host in keys(workernodes) ~}
     server ${workernodes[host]} ${host}:30001;
%{ endfor ~}
