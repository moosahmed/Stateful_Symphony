## Security group for Kubernetes Cluster
resource "aws_security_group" "kubernetes-cluster-sg" {
  vpc_id = "${var.vpc_id}"
  name   = "${terraform.workspace}-kubernetes-cluster-sg"

  tags {
    KubernetesCluster = "${var.k8s_cluster}"
    Name              = "${terraform.workspace}-kubernetes-sg"
    Environment       = "${terraform.workspace}"
    Type              = "public"
    "kubernetes.io/cluster/${var.k8s_cluster}" = "owned"
  }
}

# Permissions we add to the main security group:
# Ensure cluster machines can talk to one another
resource "aws_security_group_rule" "allow_all" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = "${aws_security_group.kubernetes-cluster-sg.id}"
  security_group_id        = "${aws_security_group.kubernetes-cluster-sg.id}"
}

resource "aws_security_group_rule" "egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.kubernetes-cluster-sg.id}"
}

# Open up port 22 for SSH into each machine
# The allowed locations are chosen by the user in the SSHLocation parameter
resource "aws_security_group_rule" "allow_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.kubernetes-cluster-sg.id}"
}