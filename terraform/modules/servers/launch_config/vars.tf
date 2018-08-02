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

## Image IDs
variable "master_image_id" {
  description = "ami id for the master image"
}

variable "node_image_id" {
  description = "ami id for the worker image"
}

## Instance Types
variable "master_instance_type" {
  description = "instance type for the master instance"
}

variable "node_instance_type" {
  description = "instance type for the worker instance"
}

## Instance Profiles
variable "master_iam_instance_profile_id" {
  description = "ID for the master iam instance profile"
}

variable "node_iam_instance_profile_id" {
  description = "ID for the node iam instance profile"
}


## Volume Types
variable "master_volume_type" {
  description = "Type of volume for the master node"
}

variable "node_volume_type" {
  description = "Type of volume for the worker node"
}

## Volume Sizes
variable "master_volume_size" {
  description = "Size of volume for the master node"
}

variable "node_volume_size" {
  description = "Size of volume for the worker node"
}
