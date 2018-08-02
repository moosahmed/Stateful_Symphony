variable "k8s_cluster" {
  description = "k8s cluster name"
}

## VPC Variables
variable "vpc_id" {
  description = "ID of the VPC to create subnet"
}

variable "igw_id" {
  description = "ID of your Internet Gateway"
}