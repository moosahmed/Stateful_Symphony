variable "aws_region" {
  description = "AWS Region"
}

variable "k8s_cluster" {
  description = "Kubernetes Cluster"
}

variable "aws_key_pair_id" {
  description = "AWS public key pair id"
}

## Security Groups
variable "security_group_id" {
  description = "ID for the security group"
}

variable "node_instance_type" {
  description = "instance type for the worker instance"
}

variable "node_iam_instance_profile_id" {
  description = "ID for the node iam instance profile"
}

variable "eks_cluster_cert_auth_0data" {
  description = ""
}

variable "eks_cluster_endpoint" {
  description = ""
}