resource "kubernetes_pod" "spark-master" {
  metadata{
    name = "${var.spark_user_name}-spark"
    labels {
      name = "${var.spark_user_name}-spark-master"
      owner = "${var.spark_user_name}"
    }
  }
  spec {
    container {
      image = "moosahmed/docker-spark:2.2.1"
      name  = "${var.spark_user_name}-spark"
      command = ["/bin/bash","-c"]
//      args = ["git clone https://github.com/CCInCharge/campsite-hot-or-not.git; apt-get update && apt-get -y install python3 && python3 get-pip.py && pip install --upgrade pip && pip install -r campsite-hot-or-not/batch/requirements.txt; tail -f /etc/hosts"]
      args = ["chmod a+rx /master.sh && /master.sh ${var.spark_user_name}"]
      env {
        name = "SPARK_MASTER_PORT"
        value = "7077"
      }
      env {
        name = "SPARK_MASTER_WEBUI_PORT"
        value = "8080"
      }
      port {
        container_port = 7077
        protocol = "TCP"
      }
      port {
        container_port = 8080
        protocol = "TCP"
      }
      port {
        container_port = 6066
        protocol = "TCP"
      }
    }
  }
}

resource "kubernetes_service" "spark-master-service" {
  "metadata" {
    name = "${var.spark_user_name}-spark"
    labels {
      name = "${var.spark_user_name}-spark"
      owner = "${var.spark_user_name}"
    }
  }
  "spec" {
    selector {
      name = "${kubernetes_pod.spark-master.metadata.0.labels.name}"
    }
    port {
      name = "data-port"
      port = 7077
      target_port = "7077"
    }
    port {
      name = "ui-port"
      port = 8080
      target_port = "8080"
    }
    port {
      name = "ex-port"
      port = 6066
      target_port = "6066"
    }
  }
}

resource "kubernetes_replication_controller" "spark-worker-rc" {
  "metadata" {
    name = "${var.spark_user_name}-spark-worker-controller"
    labels {
      name = "${var.spark_user_name}-spark-worker"
      uses = "${var.spark_user_name}-spark"
      owner = "${var.spark_user_name}"
    }
  }
  "spec" {
    replicas = 2
    "selector" {
      name = "${var.spark_user_name}-spark-worker"
    }
    "template" {
      container {
        name = "${var.spark_user_name}-spark-worker"
        image = "moosahmed/docker-spark:2.2.1"
        command = ["/bin/bash", "-c"]
        args = ["chmod a+rx /worker.sh && /worker.sh spark://${var.spark_user_name}-spark:7077"]
        env {
          name = "SPARK_WORKER_WEBUI_PORT"
          value = "8081"
        }
        port {
          container_port = 8081
          protocol = "TCP"
        }
        port {
          host_port = 8888
          container_port = 8888
        }
      }
    }
  }
}

//resource "kubernetes_pod" "spark-driver" {
//  "metadata" {
//    name = "${var.spark_user_name}-spark-driver"
//    labels {
//      name = "${var.spark_user_name}-spark-driver"
//      owner = "${var.spark_user_name}"
//    }
//  }
//  "spec" {
//    container {
//      name = "${var.spark_user_name}-spark-driver"
//      image = "guangyang/docker-spark-driver:latest"
//      command = ["tail -f /etc/hosts"]
//      env {
//        name = "TERM"
//        value = "linux"
//      }
//      env {
//        name = "HOME"
//        value = "/home/dev"
//      }
////      env {
////        name = "PYTHONPATH"
////        value = "/home/dev/plushy"
////      }
////      env {
////        name = "RUNNING_DAGS_FOLDER"
////        value = "/home/dev/dagger/dagger/dags/running"
////      }
////      env {
////        name = "PLUSHY_VERSION"
////        value = "1.6"
////      }
//      env {
//        name = "SPARK_DRIVER_MEMORY"
//        value = "3g"
//      }
//      env {
//        name = "SPARK_EXECUTOR_MEMORY"
//        value = "4g"
//      }
//      env {
//        name = "SPARK_MASTER_DNS"
//        value = "${var.spark_user_name}-spark"
//      }
//      resources {
//        requests {
//          cpu = "1300m"
//          memory = "4000Mi"
//        }
//      }
////      volume_mount {
////        mount_path = "/home/dev/airflow_config"
////        name = "airflow-config-vol"
////        read_only = false
////      }
////      volume_mount {
////        mount_path = "/home/dev/.aws"
////        name = "boto-vol"
////        read_only = false
////      }
////      volume_mount {
////        mount_path = "/usr/spark/conf"
////        name = "spark-conf-vol"
////        read_only = false
////      }
////      volume_mount {
////        mount_path = "/home/dev/.ssh"
////        name = "deploy-vol"
////        read_only = false
////      }
//    }
//////    volume {
//////      name = "airflow-config-vol"
//////      secret {
//////        secret_name = "airflow-config-secret"
//////      }
//////    }
//////    volume {
//////      name = "boto-vol"
//////      secret {
//////        secret_name = "boto-secret"
//////      }
//////    }
//////    volume {
//////      name = "spark-conf-vol"
//////      secret {
//////        secret_name = "spark-conf-secret"
//////      }
//////    }
////    volume {
////      name = "deploy-vol"
////      secret {
////        secret_name = "deploy-secret"
////      }
////    }
////    node_selector {
////      user = "${var.spark_user_name}"
////    }
//  }
//}
