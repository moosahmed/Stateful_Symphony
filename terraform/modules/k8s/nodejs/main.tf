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
    }
  }
}