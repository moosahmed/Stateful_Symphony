# docker-spark-2.2.1
docker setup for deploying spark 2.2.1 (tailored towards pyspark) on kubernetes, based on [other](https://github.com/big-data-europe/docker-spark) [peoples](https://github.com/guang/docker-spark) [existing](https://github.com/mattf/openshift-spark) [work](https://github.com/gettyimages/docker-spark)

Notice that things like port mappings are delegated to the orchestration tool.
As a result, the `terraform` provisioning for master pod should look something like. (Assuming you have a k8s cluster running, and configured properly in terraform. Take a look at terraform folder that.)
```
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
```

while the worker replication controller should look something like
```
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
```
where `${var.spark_user_name}` should be replaced with a dns-friendly name of your choosing


Love to hear feedbacks! To get started with spark on kubernetes, check out [kube's doc on spark](http://kubernetes.io/v1.1/examples/spark/README.html)
