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

resource "aws_iam_role" "master" {
  name               = "masters.${var.k8s_cluster}"
  assume_role_policy = "${file("${path.module}/data/aws_iam_role_masters.${var.k8s_cluster}_policy")}"
}

resource "aws_iam_role" "nodes" {
  name               = "nodes.${var.k8s_cluster}"
  assume_role_policy = "${file("${path.module}/data/aws_iam_role_nodes.${var.k8s_cluster}_policy")}"
}

resource "aws_iam_role_policy" "master" {
  name   = "masters.${var.k8s_cluster}"
  role   = "${aws_iam_role.master.name}"
  policy = "${file("${path.module}/data/aws_iam_role_policy_masters.${var.k8s_cluster}_policy")}"
}

resource "aws_iam_role_policy" "nodes" {
  name   = "nodes.${var.k8s_cluster}"
  role   = "${aws_iam_role.nodes.name}"
  policy = "${file("${path.module}/data/aws_iam_role_policy_nodes.${var.k8s_cluster}_policy")}"
}

resource "aws_iam_instance_profile" "master" {
  name = "masters.${var.k8s_cluster}"
  role = "${aws_iam_role.master.name}"
}

resource "aws_iam_instance_profile" "nodes" {
  name = "nodes.${var.k8s_cluster}"
  role = "${aws_iam_role.nodes.name}"
}