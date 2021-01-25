global
  daemon
  log                      /var/lib/haproxy/dev/log    local1  info
  maxconn 4096
  tune.ssl.default-dh-param 2048
  chroot                  /var/lib/haproxy

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
%{ for host in keys(backends) ~}
    acl ${backends[host].fqdn}_acl path -i -m beg /sim/${host}
%{ endfor ~}
%{ for sdk in sdks ~}
    acl ${sdk.name}_acl path -i -m beg /mockfsp/${sdk.name}
%{ endfor ~}


%{ for host in keys(backends) ~}
    use_backend ${host} if ${backends[host].fqdn}_acl
%{ endfor ~}
%{ for sdk in sdks ~}
    use_backend ${sdk.name} if ${sdk.name}_acl
%{ endfor ~}


%{ for host in keys(backends) ~}
backend ${host}
    mode http
    balance roundrobin
    server ${host} ${backends[host].fqdn} ssl crt /etc/haproxy/certificates/${host}.client.fullchain.crt ca-file /etc/haproxy/certificates/${host}_server_ca.crt verify required
    timeout connect        10s
    timeout server          1m
%{ endfor }
%{ for sdk in sdks ~}
backend ${sdk.name}
    mode http
    balance roundrobin
    http-request set-path %[path,regsub(/mockfsp/${sdk.name}/inbound,,g)]
    server ${sdk.name} ${sdk.sim_endpoint} ssl crt /etc/haproxy/certificates/${sdk.name}.client.fullchain.crt ca-file /etc/haproxy/certificates/${sdk.name}_server_ca.pem verify required
    timeout connect        10s
    timeout server          1m
%{ endfor }
