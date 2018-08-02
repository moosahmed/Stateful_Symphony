resource "aws_vpc" "symph-cluster-k8s-local" {
  cidr_block           = "${lookup(var.vpc_cidr_prefix, terraform.workspace)}.${lookup(var.vpc_cidr_suffix, terraform.workspace)}"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags {
    KubernetesCluster = "symph-cluster.k8s.local"
    Name              = "${terraform.workspace}-vpc"
    Environment       = "${terraform.workspace}"
    "kubernetes.io/cluster/symph-cluster.k8s.local" = "owned"
  }
}

resource "aws_vpc_dhcp_options" "symph-cluster-k8s-local" {
  domain_name         = "ec2.internal"
  domain_name_servers = ["AmazonProvidedDNS"]

  tags = {
    KubernetesCluster = "symph-cluster.k8s.local"
    Name              = "${terraform.workspace}-vpc-dhcp-ops"
    Environment       = "${terraform.workspace}"
    "kubernetes.io/cluster/symph-cluster.k8s.local" = "owned"
  }
}

resource "aws_vpc_dhcp_options_association" "symph-cluster-k8s-local" {
  vpc_id          = "${aws_vpc.symph-cluster-k8s-local.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.symph-cluster-k8s-local.id}"
}
