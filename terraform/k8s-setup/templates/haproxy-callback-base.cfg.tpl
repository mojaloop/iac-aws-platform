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
    option                  http-keep-alive
    bind *:80
    redirect scheme https code 301 if !{ ssl_fc }

frontend k8s-ingress
    option                  http-keep-alive
    bind :443 force-tlsv12 ciphers EECDH+CHACHA20:ECDH+AESGCM:DH+AESGCM:EECDH+AES256:DH+AES256:EECDH+AES128:DH+AES:!aNULL:!MD5:!DSS ssl crt /etc/haproxy/certificates/haproxy-callback.fullchain.crt
    http-request            set-header X-Forwarded-Proto https
    http-request            set-var(txn.txnhost) hdr(host)
    http-request            set-var(txn.txnpath) path
    #acl                     Trusted_DFSP_acl        src -f /etc/haproxy/ip_whitelist
    #http-request            deny   if  Trusted_DFSP_acl
