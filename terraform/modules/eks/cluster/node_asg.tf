resource "aws_autoscaling_group" "nodes" {
  name                 = "nodes"
  launch_configuration = "${var.node_launch_config_id}"
  desired_capacity     = 2
  max_size             = 2
  min_size             = 1
  vpc_zone_identifier  = ["${aws_subnet.public-subnet.*.id}"]

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
    key                 = "kubernetes.io/cluster/${var.k8s_cluster}"
    value               = "owned"
    propagate_at_launch = true
  }

  metrics_granularity   = "1Minute"
  enabled_metrics       = ["GroupDesiredCapacity", "GroupInServiceInstances", "GroupMaxSize", "GroupMinSize", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
}