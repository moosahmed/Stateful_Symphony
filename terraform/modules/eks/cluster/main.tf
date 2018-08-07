data "aws_availability_zones" "available" {}

resource "aws_iam_role_policy_attachment" "master-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${var.cluster_iam_role_name}"
}

resource "aws_iam_role_policy_attachment" "master-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${var.cluster_iam_role_name}"
}

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
    Type              = "public"
    "kubernetes.io/cluster/${var.k8s_cluster}" = "owned"
    "kubernetes.io/role/elb"                   = "1"
  }
}

## Route table associations
resource "aws_route_table_association" "public-subnet" {

  subnet_id      = "${aws_subnet.public-subnet.*.id[count.index]}"
  route_table_id = "${var.public_rt_id}"
}

resource "aws_eks_cluster" "cluster" {
  name     = "${var.k8s_cluster}"
  role_arn = "${var.cluster_iam_role_arn}"

  vpc_config {
    security_group_ids = ["${var.cluster_sg_id}"]
    subnet_ids         = ["${aws_subnet.public-subnet.*.id}"]
  }

  depends_on = [
    "aws_iam_role_policy_attachment.master-AmazonEKSClusterPolicy",
    "aws_iam_role_policy_attachment.master-AmazonEKSServicePolicy",
  ]
}
