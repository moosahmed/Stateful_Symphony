output "public_subnet_id" {
  description = "The ID of the Public Subnet"
  value       = "${aws_subnet.public-subnet.id}"
}

output "public_subnet_cidr_block" {
  description = "The Cidr block of Public Subnet"
  value       = "${aws_subnet.public-subnet.cidr_block}"
}

output "private_subnet_id" {
  description = "The ID of the Private Subnet"
  value       = "${aws_subnet.private-subnet.id}"
}

output "private_subnet_cidr_block" {
  description = "The Cidr block of Private Subnet"
  value       = "${aws_subnet.private-subnet.cidr_block}"
}