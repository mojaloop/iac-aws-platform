grafana:
  enabled: true
  datasources:
    datasources.yaml:
      apiVersion: 1
      datasources:
      - name: Mojaloop
        type: prometheus
        url: ${prom-mojaloop-url}
        access: proxy
        isDefault: true
  notifiers: 
    notifiers.yaml:
      notifiers:
      - name: slack-notifier
        type: slack
        uid: slack
        org_id: 1
        is_default: true
        settings:
          url: ${grafana-slack-url}
  sidecar:
    dashboards:
      enabled: true
      label: mojaloop_dashboard
      searchNamespace: ${dashboard_namespace}
  ingress:
    enabled: true
    annotations:
      cert-manager.io/cluster-issuer: letsencrypt
      kubernetes.io/ingress.class: nginx
    hosts: 
      - ${grafana_host}
    tls:
    - secretName: grafana-tls
      hosts:
        - ${grafana_host}
prometheus:
  enabled: true
  alertmanager:
    persistentVolume:
      enabled: false
  server:
    persistentVolume:
      enabled: true
      storageClass: ${storage_class_name}
loki:
  persistence:
    enabled: true
    storageClassName: ${storage_class_name}
    size: 5Gi
  config:
    table_manager:
      retention_deletes_enabled: true
      retention_period: 72h     