output "vpc_id" {
  description = "The ID of the VPC"
  value       = "${aws_vpc.symph-cluster-k8s-local.id}"
}

output "vpc_cidr_prefix" {
  description = "The first two section of the VPC Cidr"
  value       = "${lookup(var.vpc_cidr_prefix, terraform.workspace)}"
}