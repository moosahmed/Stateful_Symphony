output "region" {
  value = "${var.aws_region}"
}

output "cluster_name" {
  value = "${var.k8s_cluster}"
}

output "vpc_id" {
  value = "${module.vpc_network.vpc_id}"
}

output "security_group_ids" {
  value = ["${module.security_groups.cluster_sg_id}"]
}

output "subnet_ids" {
  value = ["${module.subnet_network.public_subnet_id}"]
}

output "masters_role_arn" {
  value = "${aws_iam_role.master.arn}"
}

output "masters_role_name" {
  value = "${aws_iam_role.master.name}"
}

output "nodes_role_arn" {
  value = "${aws_iam_role.nodes.arn}"
}

output "nodes_role_name" {
  value = "${aws_iam_role.nodes.name}"
}
