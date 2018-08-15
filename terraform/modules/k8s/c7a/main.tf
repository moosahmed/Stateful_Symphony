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
  provisioner "local-exec" {
    command = "echo '${data.template_file.deployment.rendered}' > /tmp/deployment.yaml && kubectl create --kubeconfig=$HOME/.kube/config -f /tmp/deployment.yaml"
  }
  depends_on = ["kubernetes_service.c7a-headless"]
}

data "template_file" "deployment" {
  template = "${file("${path.root}/data/c7a_statefulset.yml")}"

  //  vars {
  //    NAMESPACE                     = "${var.namespace}"
  //    DB_HOST                       = "${var.db_host}"
  //    DB_PORT                       = "${var.db_port}"
  //  }
}

resource "kubernetes_config_map" "c7a-config" {
  "metadata" {
    name = c7a-config
  }
  data {
    create_keyspaces.cql: |-
      CREATE KEYSPACE IF NOT EXISTS weather_stations WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 2 };

      CREATE KEYSPACE IF NOT EXISTS campsites WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 2 };

      CREATE TABLE weather_stations.readings (
        station_id varchar,
        measurement_time timestamp,
        lat float,
        lon float,
        temp float,
        PRIMARY KEY (station_id, measurement_time)
      ) WITH CLUSTERING ORDER BY (measurement_time DESC);

      CREATE TABLE campsites.calculations (
        campsite_id int,
        calculation_time timestamp,
        lat float,
        lon float,
        temp float,
        name varchar,
        PRIMARY KEY (campsite_id, calculation_time)
      ) WITH CLUSTERING ORDER BY (calculation_time DESC);
  }
}