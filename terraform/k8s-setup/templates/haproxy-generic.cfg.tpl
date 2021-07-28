global
    log 127.0.0.1:514  local0  info
    chroot /var/lib/haproxy
    stats socket /run/haproxy/admin.sock mode 660 level admin
    stats timeout 30s
    user haproxy
    group haproxy
    daemon

defaults
    mode http
    log global
    option httplog
    option forwardfor
    option http-server-close
    timeout client  1m
    timeout server  1m

frontend k8s-inbound
    bind *:30000
    default_backend nginx-ingress
    

backend nginx-ingress
    balance roundrobin
%{ for host in keys(workerservers) ~}
     server ${workerservers[host]} ${host}:30001;
%{ endfor ~}
    timeout connect        10s
    