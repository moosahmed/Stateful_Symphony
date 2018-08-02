resource "aws_autoscaling_group" "master" {
  name                 = "master-${var.aws_region}a.masters.${var.k8s_cluster}"
  launch_configuration = "${var.master_lc_id}"
  max_size             = 1
  min_size             = 1
  vpc_zone_identifier  = ["${var.public_subnet_id}"]

  tag = {
    key                 = "KubernetesCluster"
    value               = "${var.k8s_cluster}"
    propagate_at_launch = true
  }

  tag = {
    key                 = "Name"
    value               = "master-${var.aws_region}a.masters.${var.k8s_cluster}"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup"
    value               = "master-${var.aws_region}a"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/role/master"
    value               = "1"
    propagate_at_launch = true
  }

  metrics_granularity = "1Minute"
  enabled_metrics     = ["GroupDesiredCapacity", "GroupInServiceInstances", "GroupMaxSize", "GroupMinSize", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
}

resource "aws_autoscaling_group" "nodes" {
  name                 = "nodes."
  launch_configuration = "${var.node_lc_id}"
  max_size             = 2
  min_size             = 2
  vpc_zone_identifier  = ["${var.public_subnet_id}"]

  tag = {
    key                 = "KubernetesCluster"
    value               = "${var.k8s_cluster}"
    propagate_at_launch = true
  }

  tag = {
    key                 = "Name"
    value               = "nodes.${var.k8s_cluster}"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup"
    value               = "nodes"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/role/node"
    value               = "1"
    propagate_at_launch = true
  }

  metrics_granularity = "1Minute"
  enabled_metrics     = ["GroupDesiredCapacity", "GroupInServiceInstances", "GroupMaxSize", "GroupMinSize", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
}