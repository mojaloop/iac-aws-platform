global
    log 127.0.0.1:514  local0  info
    chroot /var/lib/haproxy
    stats socket /run/haproxy/admin.sock mode 660 level admin
    stats timeout 30s
    user haproxy
    group haproxy
    daemon
    maxconn 4096

    # Default SSL material locations
    ca-base /etc/ssl/certs
    crt-base /etc/ssl/private

    # Default ciphers to use on SSL-enabled listening sockets.xxx
    # For more information, see ciphers(1SSL). This list is from:
    #  https://hynek.me/articles/hardening-your-web-servers-ssl-ciphers/
    # An alternative list with additional directives can be obtained from
    #  https://mozilla.github.io/server-side-tls/ssl-config-generator/?server=haproxy
    ssl-default-bind-ciphers ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:RSA+AESGCM:RSA+AES:!aNULL:!MD5:!DSS
    ssl-default-bind-options no-sslv3
    ssl-dh-param-file /etc/haproxy/certs/dhparams.pem

defaults
    log     global
    mode    http
    option forwardfor
    option http-server-close
    option  httplog
    option  dontlognull
    timeout connect 5000
    timeout client  50000
    timeout server  50000
    errorfile 400 /etc/haproxy/errors/400.http
    errorfile 403 /etc/haproxy/errors/403.http
    errorfile 408 /etc/haproxy/errors/408.http
    errorfile 500 /etc/haproxy/errors/500.http
    errorfile 502 /etc/haproxy/errors/502.http
    errorfile 503 /etc/haproxy/errors/503.http
    errorfile 504 /etc/haproxy/errors/504.http


frontend localnodes
    bind *:6443
    mode tcp
    default_backend nodes

frontend http-80
    bind *:80
    mode http
    default_backend nginx-ingress

frontend http-30000
    bind *:30000
    mode http
    default_backend nginx-ingress


backend nginx-ingress
    mode http
    balance roundrobin
%{ for host in keys(workerservers) ~}
     server ${workerservers[host]} ${host}:30001;
%{ endfor ~}

backend nodes
    mode tcp
    balance roundrobin
%{ for host in keys(masterservers) ~}
    server ${masterservers[host]} ${host}:6443;
%{ endfor ~}
    timeout connect        10s
    timeout server          1m


frontend wso2
    bind *:9443 ssl crt /etc/haproxy/certs/${trimsuffix(extgw_host, ".internal")}.fullchain.crt  crt /etc/haproxy/certs/${trimsuffix(intgw_host, ".internal")}.fullchain.crt crt /etc/haproxy/certs/${trimsuffix(iskm_host, ".internal")}.fullchain.crt ca-file /etc/haproxy/certs/CA.crt verify optional crt-ignore-err all
    bind *:9843 ssl crt /etc/haproxy/certs/${trimsuffix(extgw_host, ".internal")}.fullchain.crt  crt /etc/haproxy/certs/${trimsuffix(intgw_host, ".internal")}.fullchain.crt crt /etc/haproxy/certs/${trimsuffix(iskm_host, ".internal")}.fullchain.crt ca-file /etc/haproxy/certs/CA.crt verify optional crt-ignore-err all
    #bind *:9543 ssl crt /etc/haproxy/certs/${trimsuffix(extgw_host, ".internal")}.fullchain.crt  crt /etc/haproxy/certs/${trimsuffix(intgw_host, ".internal")}.fullchain.crt crt /etc/haproxy/certs/${trimsuffix(iskm_host, ".internal")}.fullchain.crt ca-file /etc/haproxy/certs/CA.crt verify optional crt-ignore-err all
    acl restricted_path path_beg,url_dec { -m beg -i /publisher/ } || { -m beg -i /carbon/ } || { -m beg -i /admin/ }
    acl extgw-acl ssl_fc_sni ${trimsuffix(extgw_host, ".internal")}
    acl intgw-acl ssl_fc_sni ${intgw_host}
    acl iskm-acl ssl_fc_sni ${iskm_host}
    acl has-cert ssl_fc_has_crt
    acl has-good-cert ssl_c_verify 0
    acl Trusted_EXTGW_acl src -f /etc/haproxy/whitelist_extgw
    acl Trusted_INTGW_acl src -f /etc/haproxy/whitelist_intgw
    acl Trusted_ISKM_acl src -f /etc/haproxy/whitelist_iskm
    acl Trusted_PRIV_acl src -f /etc/haproxy/whitelist_priv
    #redirect location /certmissing.html if restricted_path !{ ssl_c_used 1 }
    #redirect location /certexpired.html if restricted_path { ssl_c_verify 10 }
    #redirect location /certrevoked.html if restricted_path { ssl_c_verify 23 }
    #redirect location /othererrors.html if restricted_path !{ ssl_c_verify 0 }
    http-request set-header X-Forwarded-Proto https
    http-response set-header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
    http-request set-header X-SSL                       %[ssl_fc]
    http-request set-header X-SSL-Client-Cert           %[ssl_fc_has_crt]
    http-request set-header X-SSL-Client-Verify         %[ssl_c_verify]
    http-request set-header X-SSL-Client-SHA1           %%{+Q}[ssl_c_sha1,hex]
    http-request set-header X-SSL-Client-DN             %%{+Q}[ssl_c_s_dn]
    http-request set-header X-SSL-Client-CN             %%{+Q}[ssl_c_s_dn(cn)]
    http-request set-header X-SSL-Issuer                %%{+Q}[ssl_c_i_dn]
    http-request set-header X-SSL-Client-Not-Before     %%{+Q}[ssl_c_notbefore]
    http-request set-header X-SSL-Client-Not-After      %%{+Q}[ssl_c_notafter]

    #default_backend wso2-backend
    #use_backend wso2-backend if extgw-acl Trusted_EXTGW_acl has-cert has-good-cert || extgw-acl Trusted_PRIV_acl
    #use_backend wso2-iskm if iskm-acl Trusted_ISKM_acl has-cert has-good-cert || iskm-acl Trusted_PRIV_acl
    #use_backend wso2-backend-internal if intgw-acl Trusted_INTGW_acl has-cert has-good-cert || intgw-acl Trusted_PRIV_acl
    use_backend wso2-backend if extgw-acl Trusted_EXTGW_acl
    use_backend wso2-iskm if iskm-acl Trusted_ISKM_acl
    use_backend wso2-backend-internal if intgw-acl Trusted_INTGW_acl

backend wso2-backend
    mode http
    balance roundrobin
%{ for host in keys(workerservers) ~}
    server ${workerservers[host]} ${host}:32443 ssl verify none
%{ endfor ~}

backend wso2-iskm
    mode http
    balance roundrobin
%{ for host in keys(workerservers) ~}
    server ${workerservers[host]} ${host}:31443 ssl verify none
%{ endfor ~}

backend wso2-backend-internal
    mode http
    balance roundrobin
%{ for host in keys(workerservers) ~}
    server ${workerservers[host]} ${host}:30443 ssl verify none
%{ endfor ~}

frontend wso2-api-service
    bind *:8843 ssl crt /etc/haproxy/certs/${trimsuffix(extgw_host, ".internal")}.fullchain.crt  crt /etc/haproxy/certs/${trimsuffix(intgw_host, ".internal")}.fullchain.crt ca-file /etc/haproxy/certs/CA.crt verify optional crt-ignore-err all
    bind *:8243 ssl crt /etc/haproxy/certs/${trimsuffix(extgw_host, ".internal")}.fullchain.crt  crt /etc/haproxy/certs/${trimsuffix(intgw_host, ".internal")}.fullchain.crt ca-file /etc/haproxy/certs/CA.crt verify optional crt-ignore-err all

    
    http-request set-header X-Forwarded-Proto https
    http-response set-header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
    http-request set-header X-SSL                       %[ssl_fc]
    http-request set-header X-SSL-Client-Cert           %[ssl_fc_has_crt]
    http-request set-header X-SSL-Client-Verify         %[ssl_c_verify]
    http-request set-header X-SSL-Client-SHA1           %%{+Q}[ssl_c_sha1,hex]
    http-request set-header X-SSL-Client-DN             %%{+Q}[ssl_c_s_dn]
    http-request set-header X-SSL-Client-CN             %%{+Q}[ssl_c_s_dn(cn)]
    http-request set-header X-SSL-Issuer                %%{+Q}[ssl_c_i_dn]
    http-request set-header X-SSL-Client-Not-Before     %%{+Q}[ssl_c_notbefore]
    http-request set-header X-SSL-Client-Not-After      %%{+Q}[ssl_c_notafter]

    acl Trusted_EXTGW_acl src -f /etc/haproxy/whitelist_extgw
    acl Trusted_INTGW_acl src -f /etc/haproxy/whitelist_intgw
    acl Trusted_PRIV_acl src -f /etc/haproxy/whitelist_priv
    acl has-cert ssl_fc_has_crt
    acl has-good-cert ssl_c_verify 0
    acl extgw-acl ssl_fc_sni ${trimsuffix(extgw_host, ".internal")}
    acl intgw-acl ssl_fc_sni ${intgw_host}
    
    #default_backend wso2-backend
    #use_backend wso2-api-service-backend if extgw-acl Trusted_EXTGW_acl has-cert has-good-cert || extgw-acl Trusted_PRIV_acl
    #use_backend wso2-api-service-backend-internal if intgw-acl Trusted_INTGW_acl has-cert has-good-cert || intgw-acl Trusted_PRIV_acl
    use_backend wso2-api-service-backend if extgw-acl Trusted_EXTGW_acl
    use_backend wso2-api-service-backend-internal if intgw-acl Trusted_INTGW_acl 

backend wso2-api-service-backend
    mode http
    balance roundrobin
%{ for host in keys(workerservers) ~}
     server ${workerservers[host]} ${host}:32243 ssl verify none
%{ endfor ~}

backend wso2-api-service-backend-internal
    mode http
    balance roundrobin
%{ for host in keys(workerservers) ~}
     server ${workerservers[host]} ${host}:32244 ssl verify none
%{ endfor ~}

frontend wso2-http-internal
    bind *:8844
    mode tcp
    default_backend wso2-http-backend-internal

backend wso2-http-backend-internal
    mode tcp
    balance roundrobin
%{ for host in keys(workerservers) ~}
     server ${workerservers[host]} ${host}:32245;
%{ endfor ~}

frontend wso2-http-http
    bind *:8280
    mode tcp
    default_backend wso2-http-backend-http

backend wso2-http-backend-http
    mode tcp
    balance roundrobin
%{ for host in keys(workerservers) ~}
    server ${workerservers[host]} ${host}:32280;
%{ endfor ~}
