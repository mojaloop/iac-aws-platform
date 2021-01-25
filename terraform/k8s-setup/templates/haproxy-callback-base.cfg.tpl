global
  daemon
  log                      /var/lib/haproxy/dev/log    local0  debug
  maxconn 4096
  tune.ssl.default-dh-param 2048
  chroot                          /tmp/haproxy_chroot

defaults
    mode    http
    option forwardfor
    option http-server-close

frontend http-in
    mode                    http
    log                     global
    option                  httplog
    option                  http-keep-alive
    option                  forwardfor
    log global
    bind *:80
    redirect scheme https code 301 if !{ ssl_fc }
    timeout client 1m

frontend k8s-ingress
    mode                    http
    log                     global
    option                  httplog
    option                  http-keep-alive
    option                  forwardfor
    bind :443 force-tlsv12 ciphers EECDH+CHACHA20:ECDH+AESGCM:DH+AESGCM:EECDH+AES256:DH+AES256:EECDH+AES128:DH+AES:!aNULL:!MD5:!DSS ssl crt /etc/haproxy/certificates/haproxy-callback.fullchain.crt
    mode                    http
    timeout                 client 1m
    http-request            set-header X-Forwarded-Proto https
    http-request            set-var(txn.txnhost) hdr(host)
    http-request            set-var(txn.txnpath) path
    #acl                     Trusted_DFSP_acl        src -f /etc/haproxy/ip_whitelist
    #http-request            deny   if  Trusted_DFSP_acl
