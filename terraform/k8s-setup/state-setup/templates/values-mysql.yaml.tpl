nameOverride: ${name_override}
auth:
  ## @param auth.rootPassword Password for the `root` user. Ignored if existing secret is provided
  ## ref: https://github.com/bitnami/bitnami-docker-mysql#setting-the-root-password-on-first-run
  ##
  rootPassword: ${root_password}
  ## @param auth.database Name for a custom database to create
  ## ref: https://github.com/bitnami/bitnami-docker-mysql/blob/master/README.md#creating-a-database-on-first-run
  ##
  database: ${database_name}
  ## @param auth.username Name for a custom user to create
  ## ref: https://github.com/bitnami/bitnami-docker-mysql/blob/master/README.md#creating-a-database-user-on-first-run
  ##
  username: ${database_user}
  ## @param auth.password Password for the new user. Ignored if existing secret is provided
  ##
  password: ${password}
  ## @param auth.replicationUser MySQL replication user
  ## ref: https://github.com/bitnami/bitnami-docker-mysql#setting-up-a-replication-cluster
  ##

## @section MySQL Primary parameters

primary:
  persistence:
    ## @param primary.persistence.enabled Enable persistence on MySQL primary replicas using a `PersistentVolumeClaim`. If false, use emptyDir
    ##
    enabled: true
    ## @param primary.persistence.existingClaim Name of an existing `PersistentVolumeClaim` for MySQL primary replicas
    ## NOTE: When it's set the rest of persistence parameters are ignored
    ##
    existingClaim: ""
    ## @param primary.persistence.storageClass MySQL primary persistent volume storage Class
    ## If defined, storageClassName: <storageClass>
    ## If set to "-", storageClassName: "", which disables dynamic provisioning
    ## If undefined (the default) or set to null, no storageClassName spec is
    ##   set, choosing the default provisioner.  (gp2 on AWS, standard on
    ##   GKE, AWS & OpenStack)
    ##
    storageClass: ${storage_class_name}
    ## @param primary.persistence.annotations [object] MySQL primary persistent volume claim annotations
    ##
    annotations: {}
    ## @param primary.persistence.accessModes MySQL primary persistent volume access Modes
    ##
    accessModes:
      - ReadWriteOnce
    ## @param primary.persistence.size MySQL primary persistent volume size
    ##
    size: ${storage_size}
    ## @param primary.persistence.selector [object] Selector to match an existing Persistent Volume
    ## selector:
    ##   matchLabels:
    ##     app: my-app
    ##
    selector: {}

initdbScripts:
  # This script enables legacy authentication for MySQL v8. NodeJS MySQL Client currently does not support authentication plugins, reference: https://github.com/mysqljs/mysql/pull/2233
  enableLegacyAuth.sql: |-
    ALTER USER '${database_user}'@'%' IDENTIFIED WITH mysql_native_password BY '${password}';