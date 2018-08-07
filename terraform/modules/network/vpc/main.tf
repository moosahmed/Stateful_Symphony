resource "aws_vpc" "symph-cluster-k8s-local" {
  cidr_block           = "${lookup(var.vpc_cidr_prefix, terraform.workspace)}.${lookup(var.vpc_cidr_suffix, terraform.workspace)}"

  tags {
    KubernetesCluster = "${var.k8s_cluster}"
    Name              = "${terraform.workspace}-vpc"
    Environment       = "${terraform.workspace}"
    "kubernetes.io/cluster/${var.k8s_cluster}" = "shared"
  }
}
