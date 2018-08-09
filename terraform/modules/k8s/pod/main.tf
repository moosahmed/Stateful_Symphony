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
      image = "guangyang/docker-spark:latest"
      name  = "${var.spark_user_name}-spark"
      command = ["/bin/bash", "-c", "/start-master.sh ${var.spark_user_name}"]
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
        image = "guangyang/docker-spark:latest"
        command = ["/bin/bash", "-c", "/start-worker.sh spark://${var.spark_user_name}-spark:7077"]
        port {
          host_port = 8888
          container_port = 8888
        }
      }
    }
  }
}