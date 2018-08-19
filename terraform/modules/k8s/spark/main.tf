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

resource "kubernetes_pod" "spark-driver" {
  "metadata" {
    name = "${var.spark_user_name}-spark-driver"
    labels {
      name = "${var.spark_user_name}-spark-driver"
      owner = "${var.spark_user_name}"
    }
  }
  "spec" {
    container {
      name = "${var.spark_user_name}-spark-driver"
      image = "moosahmed/docker-spark-2.2.1:latest"
      command = ["/bin/bash", "-c"]
      args = ["cp /spark/conf2/* /spark/conf/ && git clone https://github.com/moosahmed/campsite-hot-or-not.git && cd campsite-hot-or-not/batch/ && spark-submit raw_noaa_batch_s3.py"]
      env {
        name = "TERM"
        value = "linux"
      }
      env {
        name = "HOME"
        value = "/home/dev"
      }
      env {
        name = "SPARK_HOME"
        value = "/spark"
      }
      env {
        name = "SPARK_DRIVER_MEMORY"
        value = "3g"
      }
      env {
        name = "SPARK_EXECUTOR_MEMORY"
        value = "4g"
      }
      env {
        name = "SPARK_MASTER_DNS"
        value = "${var.spark_user_name}-spark"
      }
      resources {
        requests {
          cpu = "1300m"
          memory = "4000Mi"
        }
      }
      volume_mount {
        mount_path = "/spark/pyconf/"
        name = "pycfg-volume"
      }
      volume_mount {
        mount_path = "/spark/conf2/"
        name = "s3cfg-volume"
      }
    }
    volume {
      name = "pycfg-volume"
      config_map {
        name = "spark-config"
      }
    }
    volume {
      name = "s3cfg-volume"
      config_map {
        name = "s3-config"
      }
    }
  }
  depends_on = ["kubernetes_config_map.spark-config"]
}

resource "null_resource" "c7a" {
  triggers {
    c7a = "${var.c7a-ips_id}"
  }
}

data "template_file" "c7a" {
  template = "${file("${path.root}/data/cassandra-0-ip.txt")}"
  depends_on = ["null_resource.c7a"]
}

resource "kubernetes_config_map" "spark-config" {
  "metadata" {
    name = "spark-config"
  }
  data {
    s3_spark.cfg = <<EOF
[s3]
bucket_url: ${var.s3_bucket_url}
object: *.txt

[spark_cluster]
nodes: localhost

[cassandra_cluster]
host: ${data.template_file.c7a.rendered}
EOF
  }
  depends_on = ["data.template_file.c7a"]
}

resource "kubernetes_config_map" "s3-config" {
  "metadata" {
    name = "s3-config"
  }
  data {
    hdfs-site.xml = <<EOF
<?xml version="1.0"?>
<configuration>
<property>
  <name>fs.s3a.access.key</name>
  <value>${var.access_key}</value>
</property>
<property>
  <name>fs.s3a.secret.key</name>
  <value>${var.secret_key}</value>
</property>
<property>
  <name>fs.s3n.awsAccessKeyId</name>
  <value>${var.access_key}</value>
</property>
<property>
  <name>fs.s3n.awsSecretAccessKey</name>
  <value>${var.secret_key}</value>
</property>
</configuration>
EOF
  }
}