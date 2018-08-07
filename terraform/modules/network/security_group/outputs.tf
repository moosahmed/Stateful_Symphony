output "cluster_sg_id" {
  description = "The ID of the Cluster Security Group Id"
  value       = "${aws_security_group.cluster-sg.id}"
}

output "node_sg_id" {
  description = "The ID of the Node Security Group Id"
  value       = "${aws_security_group.node-sg.id}"
}