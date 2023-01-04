controller:
  kind: "DaemonSet"
  autoscaling: 
    enabled: false
  publishService:
    enabled: false
  ingressClassByName: true
  extraArgs:
    publish-status-address: ${lb_name}
    enable-ssl-passthrough: false
    default-ssl-certificate: ${tls_sec_name}
  service:
    externalTrafficPolicy: "Local"
    type: NodePort
    nodePorts:
      http: ${http_nodeport_port}
      https: ${https_nodeport_port}
  ingressClass: ${ingress_class_name}
  ingressClassResource:
    enabled: true
    default: false
    name: ${ingress_class_name}
    controllerValue: "k8s.io/${ingress_class_name}"
  admissionWebhooks:
    failurePolicy: "Ignore"
  config:
    use-proxy-protocol: ${use_proxy_protocol}
    enable-real-ip: ${enable_real_ip}
    %{ if use_proxy_protocol ~}real-ip-header: "proxy_protocol"%{ endif }
