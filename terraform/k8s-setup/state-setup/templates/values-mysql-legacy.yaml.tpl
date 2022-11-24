mysqlRootPassword: ${root_password}
mysqlUser: ${database_user}
mysqlPassword: ${password}
mysqlDatabase: ${database_name}
persistence:
  storageClass: ${storage_class_name}
  accessMode: ReadWriteOnce
  size: ${storage_size}
fullnameOverride: ${name_override}
service:
  port: ${service_port}