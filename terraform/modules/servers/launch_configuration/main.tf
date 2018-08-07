data "aws_region" "current" {}

data "aws_ami" "eks-worker" {
  filter {
    name   = "name"
    values = ["eks-worker-*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon
}

data "template_file" "worker-userdata" {
  template = "${file("${path.root}/data/worker.sh")}"

  vars {
    eks_cluster_cert_auth_0data = "${var.eks_cluster_cert_auth_0data}"
    k8s_cluster = "${var.k8s_cluster}"
    eks_cluster_endpoint = "${var.eks_cluster_endpoint}"
    aws_region = "${data.aws_region.current.name}"
  }
}

resource "aws_launch_configuration" "nodes" {
  name_prefix                 = "nodes.${var.k8s_cluster}-"
  image_id                    = "${data.aws_ami.eks-worker.id}"
  instance_type               = "${var.node_instance_type}"
  iam_instance_profile        = "${var.node_iam_instance_profile_id}"
  security_groups             = ["${var.security_group_id}"]
  associate_public_ip_address = true
  user_data_base64 = "${base64encode(data.template_file.worker-userdata.rendered)}"

  lifecycle = {
    create_before_destroy = true
  }
}