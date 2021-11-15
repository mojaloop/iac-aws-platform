server:
  enabled: true
  dev: 
    enabled: false
  ha:
    enabled: true 
    config: |
      ui = true
      listener "tcp" {
        tls_disable = 1
        address = "[::]:8200"
        cluster_address = "[::]:8201"
      }
      storage "consul" {
        path = "vault"
        address = "consul-server:8500"
      }
      service_registration "kubernetes" {}
      # Example configuration for using auto-unseal, using Google Cloud KMS. The
      # GKMS keys must already exist, and the cluster must have a service account
      # that is authorized to access GCP KMS.
      seal "awskms" {
        region = "${aws_region}"
        kms_key_id = "${kms_key_id}"
        access_key = "${kms_access_key}"
        secret_key = "${kms_secret_key}"
      }

  extraContainers:
    - name: statsd-exporter
      image: prom/statsd-exporter:latest

  affinity: 
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: class
            operator: NotIn
            values:
            - vault
    podAntiAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        podAffinityTerm:
          topologyKey: kubernetes.io/hostname
          labelSelector:
            matchLabels:
              app: vault
ui:
  enabled: true
  serviceType: LoadBalancer
  externalPort: 80
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-backend-protocol: http
    service.beta.kubernetes.io/aws-load-balancer-connection-idle-timeout: "3600"
    service.beta.kubernetes.io/aws-load-balancer-internal: 0.0.0.0

injector:
  enabled: true
  authPath: auth/${kube_engine_path}
csi:
  enabled: false