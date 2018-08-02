resource "aws_launch_configuration" "master" {
  name_prefix                 = "master-${var.aws_region}a.masters.${var.k8s_cluster}-"
  image_id                    = "${var.master_image_id}"
  instance_type               = "${var.master_instance_type}"
  key_name                    = "${var.aws_key_pair_id}"
  iam_instance_profile        = "${var.master_iam_instance_profile_id}"
  security_groups             = ["${var.security_group_id}"]
  associate_public_ip_address = true
  user_data                   = "${file("${path.module}/data/aws_launch_configuration_master-us-west-2a.masters.moosahmed.com_user_data")}"

  root_block_device = {
    volume_type           = "${var.master_volume_type}"
    volume_size           = "${var.master_volume_size}"
    delete_on_termination = true
  }

  lifecycle = {
    create_before_destroy = true
  }

  enable_monitoring = false
}

resource "aws_launch_configuration" "nodes" {
  name_prefix                 = "nodes.${var.k8s_cluster}-"
  image_id                    = "${var.node_image_id}"
  #  image_id                   = "ami-4bfe6f33"
  instance_type               = "${var.node_instance_type}"
  #  instance_type               = "t2.micro"
  key_name                    = "${var.aws_key_pair_id}"
  iam_instance_profile        = "${var.node_iam_instance_profile_id}"
  security_groups             = ["${var.security_group_id}"]
  associate_public_ip_address = true
  user_data                   = "${file("${path.module}/data/aws_launch_configuration_nodes.moosahmed.com_user_data")}"

  root_block_device = {
    volume_type           = "${var.node_volume_type}"
    volume_size           = "${var.node_volume_size}"
    delete_on_termination = true
  }

  lifecycle = {
    create_before_destroy = true
  }

  enable_monitoring = false
}