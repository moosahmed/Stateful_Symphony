resource "aws_s3_bucket" "symph.k8s.state" {
  bucket = "symph.k8s.state"

  versioning {
    enabled = true
  }

  tags {
    KubernetesCluster = "${var.k8s_cluster}"
    Name              = "symph.k8s.state"
  }
}