## Public Routetable
resource "aws_route_table" "public-rt" {
  vpc_id = "${var.vpc_id}"

  # Default route through Internet Gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${var.igw_id}"
  }

  tags {
    KubernetesCluster = "${var.k8s_cluster}"
    Name              = "${terraform.workspace}"
    Environment       = "${terraform.workspace}"
  }
}

## Private Routetable
resource "aws_route_table" "private-rt" {
  vpc_id = "${var.vpc_id}"

  tags {
    Name        = "${terraform.workspace}-private-rt"
    Environment = "${terraform.workspace}"
    Type        = "public"
  }
}