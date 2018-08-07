resource "aws_key_pair" "kubernetes" {
  key_name   = "pub_key"
  public_key = "${file("${path.root}/data/aws_key_pair_public_key")}"
}

resource "aws_iam_role" "master" {
  name               = "masters.${var.k8s_cluster}"
  assume_role_policy = "${file("${path.root}/data/aws_iam_role_masters_policy")}"
}

resource "aws_iam_role" "node" {
  name               = "nodes.${var.k8s_cluster}"
  assume_role_policy = "${file("${path.root}/data/aws_iam_role_nodes_policy")}"
}

resource "aws_iam_role_policy_attachment" "master-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.master.name}"
}

resource "aws_iam_role_policy_attachment" "master-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.master.name}"
}

resource "aws_iam_role_policy_attachment" "node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = "${aws_iam_role.node.name}"
}

resource "aws_iam_role_policy_attachment" "node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = "${aws_iam_role.node.name}"
}

resource "aws_iam_role_policy_attachment" "node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = "${aws_iam_role.node.name}"
}

resource "aws_iam_instance_profile" "node" {
  name = "nodes.${var.k8s_cluster}"
  role = "${aws_iam_role.node.name}"
}

resource "aws_iam_group" "iam-group" {
  name = "iam-group"
}

resource "aws_iam_group_policy_attachment" "iam-group-ec2" {
  group      = "${aws_iam_group.iam-group.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_group_policy_attachment" "iam-group-route53" {
  group      = "${aws_iam_group.iam-group.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonRoute53FullAccess"
}

resource "aws_iam_group_policy_attachment" "iam-group-s3" {
  group      = "${aws_iam_group.iam-group.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_group_policy_attachment" "iam-group-iam" {
  group      = "${aws_iam_group.iam-group.name}"
  policy_arn = "arn:aws:iam::aws:policy/IAMFullAccess"
}

resource "aws_iam_group_policy_attachment" "iam-group-vpc" {
  group      = "${aws_iam_group.iam-group.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonVPCFullAccess"
}
