resource "kubernetes_pod" "nodejs" {
  metadata{
    name = "nodejs"
    labels {
      name = "nodejs"
    }
  }
  spec {
    container {
      image = "moosahmed/docker-nodejs-8:1.0"
      name  = "nodejs"
      command = ["/bin/bash","-c", "./start.sh"]
      env {
        name = "CASSANDRA_HOST1"
        value = "10.0.1.187"
      }
      env {
        name = "CASSANDRA_HOST2"
        value = "10.0.0.175"
      }
      env {
        name = "GOOGLE_MAPS_API_KEY"
        value = "AIzaSyCMpxfJ4SlUkk-7Cq2FazWxfjxnKxA-Sl4"
      }
      port {
        container_port = 3000
        protocol = "TCP"
      }
    }
  }
}

resource "kubernetes_service" "nodejs" {
  "metadata" {
    name = "nodejs"
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
  }
}