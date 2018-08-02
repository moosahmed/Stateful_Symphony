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
  value = "${module.iam_global.iam_role_master_arn}"
}

output "masters_role_name" {
  value = "${module.iam_global.iam_role_master_name}"
}

output "nodes_role_arn" {
  value = "${module.iam_global.iam_role_node_arn}"
}

output "nodes_role_name" {
  value = "${module.iam_global.iam_role_node_name}"
}
