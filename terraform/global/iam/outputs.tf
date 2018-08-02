output "master_iam_instance_profile_id" {
  value = "${aws_iam_instance_profile.master.id}"
}

output "node_iam_instance_profile_id" {
  value = "${aws_iam_instance_profile.node.id}"
}

output "aws_key_pair_id" {
  value = "${aws_key_pair.kubernetes.id}"
}