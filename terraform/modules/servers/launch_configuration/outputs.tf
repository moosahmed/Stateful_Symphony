output "node_launch_config_id" {
  description = "The ID of the worker launch configuration"
  value       = "${aws_launch_configuration.nodes.id}"
}