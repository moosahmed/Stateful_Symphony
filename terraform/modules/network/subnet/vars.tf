variable "aws_region" {
  description = "AWS Region"
}

variable "k8s_cluster" {
  description = "Kubernetes Cluster"
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
variable "private_rt_id" {
  description = "ID of the Private Route Table"
}