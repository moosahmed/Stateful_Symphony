variable "k8s_cluster" {
  description = "Kubernetes Cluster"
}

variable "cluster_sg_id" {
  description = "ID of the cluster's security group"
}

variable "cluster_iam_role_arn" {
  description = "Cluster's iam role arn"
}

variable "cluster_iam_role_name" {
  description = "Cluster's iam role name"
}

## VPC Variables
variable "vpc_id" {
  description = "ID of the VPC to create subnet"
}

variable "vpc_cidr_prefix" {
  description = "First 2 section of the VPC Cidr to create "
}

## Route Table
variable "public_rt_id" {
  description = "ID of the Public Route Table"
}

## Launch Config
variable "node_launch_config_id" {
  description = "ID of the Launch Configuration for the worker node"
}
