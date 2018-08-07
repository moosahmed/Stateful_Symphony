## Security group for EKS Cluster
resource "aws_security_group" "cluster-sg" {
  vpc_id = "${var.vpc_id}"
  name   = "${terraform.workspace}-cluster-sg"

  tags {
    KubernetesCluster = "${var.k8s_cluster}"
    Name              = "${terraform.workspace}-cluster-sg"
    Environment       = "${terraform.workspace}"
    Type              = "public"
    "kubernetes.io/cluster/${var.k8s_cluster}" = "owned"
  }
}

resource "aws_security_group_rule" "egress_all-cluster" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.cluster-sg.id}"
}

# Open up port 22 for SSH into each machine
# The allowed locations are chosen by the user in the SSHLocation parameter
resource "aws_security_group_rule" "allow_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.cluster-sg.id}"
}

resource "aws_security_group_rule" "cluster-ingress-workstation-https" {
  description       = "Allow workstation to communicate with the cluster API Server"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.cluster-sg.id}"
  cidr_blocks       = ["${var.workstation-external-cidr}"]
}

resource "aws_security_group" "node-sg" {
  description = "Security group fpr all nodes in the cluster"
  vpc_id      = "${var.vpc_id}"
  name        = "${terraform.workspace}-node-sg"

  tags {
    KubernetesCluster = "${var.k8s_cluster}"
    Name              = "${terraform.workspace}-node-sg"
    Environment       = "${terraform.workspace}"
    Type              = "public"
    "kubernetes.io/cluster/${var.k8s_cluster}" = "owned"
  }
}

resource "aws_security_group_rule" "cluster-ingress-node-https" {
  description              = "Allow pods to communicate with the cluster API Server"
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.cluster-sg.id}"
  source_security_group_id = "${aws_security_group.node-sg.id}"
}

resource "aws_security_group_rule" "egress_all-node" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.node-sg.id}"
}

resource "aws_security_group_rule" "node-ingress-self" {
  description              = "Allow node to communicate with each other"
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.node-sg.id}"
  source_security_group_id = "${aws_security_group.node-sg.id}"
}

resource "aws_security_group_rule" "node-ingress-cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  type                     = "ingress"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.node-sg.id}"
  source_security_group_id = "${aws_security_group.cluster-sg.id}"
}