resource "kubernetes_service" "c7a-headless" {
  "metadata" {
    name = "${terraform.workspace}-cassandra"
    labels {
      app = "${terraform.workspace}-cassandra"
    }
  }
  "spec" {
    cluster_ip = "None"
    port {
      port = 9042
      name = "cql"
    }
    selector {
      app = "${terraform.workspace}-cassandra"
    }
  }
}

resource "kubernetes_persistent_volume" "c7a-data-1" {
  "metadata" {
    name = "${terraform.workspace}-cassandra-data-1"
    labels {
      type = "local"
      app = "${terraform.workspace}-cassandra"
    }
  }
  "spec" {
    access_modes = ["ReadWriteOnce"]
    "capacity" {
      storage = "1Gi"
    }
    "persistent_volume_source" {
      host_path {
        path = "/tmp/data/${terraform.workspace}-cassandra-data-1"
      }
    }
    persistent_volume_reclaim_policy = "Recycle"
  }
}

resource "kubernetes_persistent_volume" "c7a-data-2" {
  "metadata" {
    name = "${terraform.workspace}-cassandra-data-2"
    labels {
      type = "local"
      app = "${terraform.workspace}-cassandra"
    }
  }
  "spec" {
    access_modes = ["ReadWriteOnce"]
    "capacity" {
      storage = "1Gi"
    }
    "persistent_volume_source" {
      host_path {
        path = "/tmp/data/${terraform.workspace}-cassandra-data-2"
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
    echo '${data.template_file.deployment.rendered}' > /tmp/deployment.yaml &&
    kubectl delete --kubeconfig=$HOME/.kube/config --ignore-not-found=true -f /tmp/deployment.yaml &&
    kubectl apply --kubeconfig=$HOME/.kube/config -f /tmp/deployment.yaml &&
    sleep 60 &&
    kubectl exec -it ${terraform.workspace}-cassandra-0 -- cqlsh -f scripts/create_keyspaces
  EOF
  }
  depends_on = ["kubernetes_config_map.c7a-config"]
}

data "template_file" "deployment" {
  template = "${file("${path.root}/data/c7a_statefulset.yml")}"
  vars {
    tf_workspace = "${terraform.workspace}"
  }
}

resource "kubernetes_config_map" "c7a-config" {
  "metadata" {
    name = "${terraform.workspace}-c7a-config"
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
    kubectl get pod ${terraform.workspace}-cassandra-0 -o json | jq -r '.status.podIP' | tr -d '\n' > "${path.root}/data/${terraform.workspace}-cassandra-0-ip.txt";
    kubectl get pod ${terraform.workspace}-cassandra-1 -o json | jq -r '.status.podIP' | tr -d '\n' > "${path.root}/data/${terraform.workspace}-cassandra-1-ip.txt";
  EOF
  }
  depends_on = ["null_resource.c7a-statefulset"]
}