fullnameOverride: "reporting-events-db"

auth:
  rootUser: root
  rootPassword: "rootPassword"
  username: "user"
  password: "password"
  database: "default"

resources:
  requests:
    cpu: 10m
    memory: 256Mi

persistence:
  enabled: false
  accessModes:
    - ReadWriteOnce
  size: 8Gi
  annotations: {}