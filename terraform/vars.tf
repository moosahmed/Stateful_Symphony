variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-west-2"
}

variable "k8s_cluster" {
  description = "Kubernetes cluster to deploy"
  default     = "symph-cluster.k8s.local"
}

variable "s3_bucket_name" {
  description = "Must be a globally unique bucket name across aws"
  default = "symph.k8s.state"
}