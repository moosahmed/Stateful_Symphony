output "eks_cluster_endpoint" {
  value = "${aws_eks_cluster.cluster.endpoint}"
}

output "eks_cluster_cert_auth_0data" {
  value = "${aws_eks_cluster.cluster.certificate_authority.0.data}"
}
