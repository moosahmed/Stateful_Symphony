resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "${terraform.workspace}-aws-auth"
    namespace = "${terraform.workspace}-kube-system"
  }

  data {
    mapRoles = <<YAML
- rolearn: ${var.node_iam_role_arn}
  username: system:node:{{EC2PrivateDNSName}}
  groups:
    - system:bootstrappers
    - system:nodes
YAML
  }
}