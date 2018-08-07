output "node_iam_instance_profile_id" {
  value = "${aws_iam_instance_profile.node.id}"
}

output "aws_key_pair_id" {
  value = "${aws_key_pair.kubernetes.id}"
}

output "iam_role_master_arn" {
  value = "${aws_iam_role.master.arn}"
}

output "iam_role_master_name" {
  value = "${aws_iam_role.master.name}"
}

output "iam_role_node_arn" {
  value = "${aws_iam_role.node.arn}"
}

output "iam_role_node_name" {
  value = "${aws_iam_role.node.name}"
}
