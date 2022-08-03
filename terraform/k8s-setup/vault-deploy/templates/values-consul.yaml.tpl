global:
  name: consul
  enabled: false
  gossipEncryption:
    autoGenerate: true
server:
  enabled: true
  storage: 5Gi
  storageClass: ${storage_class_name}
  replicas: ${num_replicas}