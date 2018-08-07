variable "aws_region" {
  description = "AWS Region"
}

variable "k8s_cluster" {
  description = "Kubernetes Cluster"
}

## Subnet Variables
variable "public_subnet_id" {
  description = "ID of the subnet to create the ASG"
}

variable "node_launch_config_id" {
  description = "ID of the Launch Configuration for the worker node"
}