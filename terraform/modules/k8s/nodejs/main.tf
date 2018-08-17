resource "kubernetes_pod" "nodejs" {
  metadata{
    name = "nodejs"
    labels {
      name = "nodejs"
    }
  }
  spec {
    container {
      image = "moosahmed/docker-nodejs-8:latest"
      name  = "nodejs"
      command = ["/bin/bash","-c", "./start.sh"]
      env {
        name = "CASSANDRA_HOST1"
        value = "10.0.1.95"
      }
      env {
        name = "CASSANDRA_HOST2"
        value = "10.0.0.96"
      }
      env {
        name = "GOOGLE_MAPS_API_KEY"
        value = "AIzaSyCAqXdRN7V8o_6lRJZlmX-jy237TVx5TkQ"
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