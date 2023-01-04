resource "kubernetes_job" "mysql_int" {
  metadata {
    name      = "mysql-init-int"
    namespace = var.namespace
  }
  spec {
    template {
      metadata {}
      spec {
        container {
          name    = "mysql-init-int"
          image   = "mysql:5.7-debian"
          command = ["/bin/bash", "-c", "apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 467B942D3A79BD29 && apt update && apt install git -y && git clone -b ${var.wso2_mysql_repo_version} https://github.com/mojaloop/wso2-mysql.git && cd wso2-mysql && ./mysql-init.sh -h ${var.db_host} -u root -p ${var.db_root_password} -l int -r 260 -d y"]
        }
        restart_policy = "Never"
      }
    }
    #ttl_seconds_after_finished = 60
    backoff_limit = 4  
  }
  timeouts {
    create = "3m"
    update = "3m"
  }
}

resource "kubernetes_job" "mysql_ext" {
  metadata {
    name      = "mysql-init-ext"
    namespace = var.namespace
  }
  spec {
    template {
      metadata {}
      spec {
        container {
          name    = "mysql-init-ext"
          image   = "mysql:5.7-debian"
          command = ["/bin/bash", "-c", "apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 467B942D3A79BD29 && apt update && apt install git -y && git clone -b ${var.wso2_mysql_repo_version} https://github.com/mojaloop/wso2-mysql.git && cd wso2-mysql && ./mysql-init.sh -h ${var.db_host} -u root -p ${var.db_root_password} -l ext -r 260 -d y"]
        }
        restart_policy = "Never"
      }
    }
    backoff_limit = 4
    #ttl_seconds_after_finished = 60
  }
  timeouts {
    create = "3m"
    update = "3m"
  }
}
