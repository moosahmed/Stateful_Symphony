resource "aws_vpc" "theCity" {
  cidr_block = "${lookup(var.vpc_cidr_prefix, terraform.workspace)}.${lookup(var.vpc_cidr_suffix, terraform.workspace)}"
  enable_dns_hostnames = true

  tags {
    Name = "${terraform.workspace}-vpc"
    Environment = "${terraform.workspace}"
  }
}