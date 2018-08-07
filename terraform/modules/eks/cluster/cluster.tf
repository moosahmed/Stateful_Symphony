resource "aws_iam_role_policy_attachment" "master-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${var.cluster_iam_role_name}"
}

resource "aws_iam_role_policy_attachment" "master-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${var.cluster_iam_role_name}"
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
