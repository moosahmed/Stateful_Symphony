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
      image = "moosahmed/docker-spark-2.2.1:latest"
      name  = "${var.spark_user_name}-spark"
      command = ["/bin/bash","-c"]
      args = ["/master.sh ${var.spark_user_name}"]

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
        image = "moosahmed/docker-spark-2.2.1:latest"
        command = ["/bin/bash", "-c"]
        args = ["/worker.sh spark://${var.spark_user_name}-spark:7077"]
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
//      image = "moosahmed/docker-spark-2.2.1:latest"
//      command = ["tail -f /etc/hosts"]
//      env {
//        name = "TERM"
//        value = "linux"
//      }
//      env {
//        name = "HOME"
//        value = "/home/dev"
//      }
//      env {
//        name = "SPARK_HOME"
//        value = "/spark"
//      }
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
//    }
//  }
//}
