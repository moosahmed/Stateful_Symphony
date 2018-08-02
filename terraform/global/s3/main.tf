resource "aws_s3_bucket" "symph.k8s.state" {
  bucket = "symph.k8s.state"

  versioning {
    enabled = true
  }

  tags {
    Name              = "symph.k8s.state"
    KubernetesCluster = "symph-cluster.k8s.local"
  }
}