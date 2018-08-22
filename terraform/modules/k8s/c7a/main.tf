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

resource "null_resource" "c7a-statefulset" {
  triggers {
    conifg_map = "${kubernetes_config_map.c7a-config.data.create_keyspaces}"
  }
  provisioner "local-exec" {
    command = <<EOF
    echo '${data.template_file.kubeconfig.rendered}' > $HOME/.kube/config &&
    echo '${data.template_file.statefulset.rendered}' > /tmp/statefulset.yaml &&
    kubectl delete --kubeconfig=$HOME/.kube/config --ignore-not-found=true -f /tmp/statefulset.yaml &&
    kubectl create --kubeconfig=$HOME/.kube/config -f /tmp/statefulset.yaml &&
    sleep 300 &&
    kubectl exec cassandra-0 -- cqlsh -f scripts/create_keyspaces
  EOF
  }
  depends_on = ["kubernetes_config_map.c7a-config"]
}

data "template_file" "statefulset" {
  template = "${file("${path.root}/data/c7a_statefulset.yml")}"
  vars {
    tf_workspace = "${terraform.workspace}"
  }
}

data "template_file" "kubeconfig" {
  template = "${file("${path.root}/data/kubeconfig.yml")}"
  vars {
    tf_workspace = "${terraform.workspace}"
    k8s_cluster = "${var.k8s_cluster}"
    eks_cluster_endpoint = "${var.eks_cluster_endpoint}"
    eks_cluster_cert_auth = "${var.eks_cluster_cert_auth_0data}"
  }
}

resource "kubernetes_config_map" "c7a-config" {
  "metadata" {
    name = "c7a-config"
  }
  data {
    create_keyspaces = <<EOF

      CREATE KEYSPACE IF NOT EXISTS weather_stations WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 2 };

      CREATE KEYSPACE IF NOT EXISTS campsites WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 2 };

      CREATE TABLE IF NOT EXISTS weather_stations.readings (
        station_id varchar,
        measurement_time timestamp,
        lat float,
        lon float,
        temp float,
        PRIMARY KEY (station_id, measurement_time)
      ) WITH CLUSTERING ORDER BY (measurement_time DESC);

      CREATE TABLE IF NOT EXISTS campsites.calculations (
        campsite_id int,
        calculation_time timestamp,
        lat float,
        lon float,
        temp float,
        name varchar,
        PRIMARY KEY (campsite_id, calculation_time)
      ) WITH CLUSTERING ORDER BY (calculation_time DESC);
  EOF
  }
  depends_on = ["kubernetes_service.c7a-headless"]
}

resource "null_resource" "c7a-ips" {
  triggers {
    null_res = "${null_resource.c7a-statefulset.id}"
  }
  provisioner "local-exec" {
    command = <<EOF
    kubectl get pod cassandra-0 -o json | jq -r '.status.podIP' | tr -d '\n' > "${path.root}/data/cassandra-0-ip.txt";
    kubectl get pod cassandra-1 -o json | jq -r '.status.podIP' | tr -d '\n' > "${path.root}/data/cassandra-1-ip.txt";
  EOF
  }
  depends_on = ["null_resource.c7a-statefulset"]
}