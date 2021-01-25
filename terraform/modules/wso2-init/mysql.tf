resource "helm_release" "mysql" {
  name       = "mysql-wso2"
  repository = "https://charts.helm.sh/stable"
  chart      = "mysql"
  version    = var.mysql_version
  namespace  = "mysql-wso2"
  set {
    name  = "mysqlRootPassword"
    value = var.db_root_password
  }

  set {
    name  = "mysqlUser"
    value = var.db_username
  }
  set {
    name  = "mysqlPassword"
    value = var.db_password
  }

  set {
    name  = "mysqlDatabase"
    value = var.db_name
  }
  set {
    name  = "persistence.storageClass"
    value = "slow"
  }

  set {
    name  = "persistence.accessMode"
    value = "ReadWriteOnce"
  }
  set {
    name  = "persistence.size"
    value = "8Gi"
  }
  depends_on = [kubernetes_storage_class.wso2]
}

resource "kubernetes_job" "mysql_int" {
  metadata {
    name      = "mysql-init-int"
    namespace = "mysql-wso2"
  }
  spec {
    template {
      metadata {}
      spec {
        container {
          name    = "mysql-init-int"
          image   = "mysql:5.7"
          command = ["/bin/bash", "-c", "apt update && apt install git -y && git clone -b ${var.wso2_mysql_repo_version} https://github.com/mojaloop/wso2-mysql.git && cd wso2-mysql && ./mysql-init.sh -h ${var.db_host} -u root -p ${var.db_root_password} -l int -r 260 -d y"]
        }
        restart_policy = "Never"
      }
    }
    #ttl_seconds_after_finished = 60
    backoff_limit = 4
  }
  depends_on = [helm_release.mysql]
}

resource "kubernetes_job" "mysql_ext" {
  metadata {
    name      = "mysql-init-ext"
    namespace = "mysql-wso2"
  }
  spec {
    template {
      metadata {}
      spec {
        container {
          name    = "mysql-init-ext"
          image   = "mysql:5.7"
          command = ["/bin/bash", "-c", "apt update && apt install git -y && git clone -b ${var.wso2_mysql_repo_version} https://github.com/mojaloop/wso2-mysql.git && cd wso2-mysql && ./mysql-init.sh -h ${var.db_host} -u root -p ${var.db_root_password} -l ext -r 260 -d y"]
        }
        restart_policy = "Never"
      }
    }
    backoff_limit = 4
    #ttl_seconds_after_finished = 60
  }
  depends_on = [helm_release.mysql]
}
