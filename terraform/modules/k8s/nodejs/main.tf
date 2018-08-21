resource "null_resource" "c7a" {
  triggers {
    c7a = "${var.c7a-ips_id}"
  }
}

data "template_file" "c7a-0" {
  template = "${file("${path.root}/data/${terraform.workspace}-cassandra-0-ip.txt")}"
  depends_on = ["null_resource.c7a"]
}

data "template_file" "c7a-1" {
  template = "${file("${path.root}/data/${terraform.workspace}-cassandra-1-ip.txt")}"
  depends_on = ["null_resource.c7a"]
}

resource "kubernetes_pod" "nodejs" {
  metadata{
    name = "${terraform.workspace}-nodejs"
    labels {
      name = "${terraform.workspace}-nodejs"
    }
  }
  spec {
    container {
      image = "moosahmed/docker-nodejs-8:3.0"
      name  = "nodejs"
      command = ["/bin/bash","-c", "./start.sh"]
      env {
        name = "CASSANDRA_HOST1"
        value = "${data.template_file.c7a-0.rendered}"
      }
      env {
        name = "CASSANDRA_HOST2"
        value = "${data.template_file.c7a-1.rendered}"
      }
      env {
        name = "GOOGLE_MAPS_API_KEY"
        value = "AIzaSyCm-7rpg6sIKbr4sr7n7MOGpsIf1lUepeA"
      }
      port {
        container_port = 3000
        protocol = "TCP"
      }
    }
  }
  depends_on = ["data.template_file.c7a-0"]
}

resource "kubernetes_service" "nodejs" {
  "metadata" {
    name = "${terraform.workspace}-nodejs"
  }
  "spec" {
    selector {
      name = "${kubernetes_pod.nodejs.metadata.0.labels.name}"
    }
    port {
      port = 80
      target_port = "3000"
      protocol = "TCP"
    }
//    port {
//      port = 80
//      target_port = "8080"
//    }
  }
}