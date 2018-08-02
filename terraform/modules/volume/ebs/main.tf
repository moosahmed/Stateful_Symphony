resource "aws_ebs_volume" "a-etcd" {
  availability_zone = "${var.aws_region}"
  size              = 20
  type              = "gp2"
  encrypted         = false

  tags = {
    KubernetesCluster                     = "${var.k8s_cluster}"
    Name                                  = "a.etcd.${var.k8s_cluster}"
    "k8s.io/etcd/events"                  = "a/a"
    "k8s.io/role/master"                  = "1"
    "kubernetes.io/cluster/moosahmed.com" = "owned"
  }
}