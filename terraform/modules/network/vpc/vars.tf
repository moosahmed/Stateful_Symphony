## VPC SETUP

variable "k8s_cluster" {
  description = "Kubernetes Cluster"
}

variable "vpc_cidr_prefix" {
  type = "map"
  default = {
    "dev" = "10.0"
    "tqa" = "10.2"
    "stg" = "10.3"
    "prd" = "10.10"
  }
}

variable "vpc_cidr_suffix" {
  type = "map"
  default = {
    "dev" = "0.0/16"
    "tqa" = "0.0/16"
    "stg" = "0.0/16"
    "prd" = "0.0/16"
  }
}