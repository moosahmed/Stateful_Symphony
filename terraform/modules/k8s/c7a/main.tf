resource "kubernetes_service" "c7a-headless" {
  "metadata" {
    name = "cassandra"
    labels {
      app = "cassandra"
    }
  }
  "spec" {
    cluster_ip = "None"
    port {
      port = 9042
      name = "cql"
    }
    selector {
      app = "cassandra"
    }
  }
}

resource "kubernetes_persistent_volume" "c7a-data-1" {
  "metadata" {
    name = "cassandra-data-1"
    labels {
      type = "local"
      app = "cassandra"
    }
  }
  "spec" {
    access_modes = ["ReadWriteOnce"]
    "capacity" {
      storage = "1Gi"
    }
    "persistent_volume_source" {
      host_path {
        path = "/tmp/data/cassandra-data-1"
      }
    }
    persistent_volume_reclaim_policy = "Recycle"
  }
}

resource "kubernetes_persistent_volume" "c7a-data-2" {
  "metadata" {
    name = "cassandra-data-2"
    labels {
      type = "local"
      app = "cassandra"
    }
  }
  "spec" {
    access_modes = ["ReadWriteOnce"]
    "capacity" {
      storage = "1Gi"
    }
    "persistent_volume_source" {
      host_path {
        path = "/tmp/data/cassandra-data-2"
      }
    }
    persistent_volume_reclaim_policy = "Recycle"
  }
}

provisioner "local-exec" {
  command = "echo '${data.template_file.deployment.rendered}' > /tmp/deployment.yaml && kubectl apply --kubeconfig=$HOME/.kube/config -f /tmp/deployment.yaml"
}

data "template_file" "deployment" {
  template = "${file("${path.root}/data/c7a_statefulset.yml")}"

//  vars {
//    NAMESPACE                     = "${var.namespace}"
//    DB_HOST                       = "${var.db_host}"
//    DB_PORT                       = "${var.db_port}"
//  }
}