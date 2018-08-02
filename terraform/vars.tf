variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-west-2"
}

variable "k8s_cluster" {
  description = "Kubernetes cluster to deploy"
  default     = "symph-cluster.k8s.local"
}
