apiVersion: longhorn.io/v1beta1
kind: RecurringJob
metadata:
  name: backup-1
  namespace: longhorn-system
spec:
  cron: "0 * * * *"
  task: "backup"
  groups:
  - default
  retain: 2
  concurrency: 2