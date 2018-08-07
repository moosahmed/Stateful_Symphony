data "aws_availability_zones" "available" {}

## Public Subnet
resource "aws_subnet" "public-subnet" {
  count = 2

  vpc_id            = "${var.vpc_id}"
  cidr_block        = "${var.vpc_cidr_prefix}.${count.index}.0/24"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"

  tags {
    KubernetesCluster = "${var.k8s_cluster}"
    Name              = "${terraform.workspace}-public-subnet"
    Environment       = "${terraform.workspace}"
    "kubernetes.io/cluster/${var.k8s_cluster}" = "shared"
  }
}

## Route table associations
resource "aws_route_table_association" "public-subnet" {
  count = 2

  subnet_id      = "${aws_subnet.public-subnet.*.id[count.index]}"
  route_table_id = "${var.public_rt_id}"
}