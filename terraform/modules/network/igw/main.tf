## IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = "${var.vpc_id}"

  tags {
    KubernetesCluster = "${var.k8s_cluster}"
    Name = "${terraform.workspace}-igw"
    Environment = "${terraform.workspace}"
    "kubernetes.io/cluster/${var.k8s_cluster}" = "owned"
  }
}