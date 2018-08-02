resource "aws_s3_bucket" "${var.bucket_name}" {
  bucket = "${var.bucket_name}"

  versioning {
    enabled = true
  }

  tags {
    KubernetesCluster = "${var.k8s_cluster}"
    Name              = "${var.bucket_name}"
  }
}