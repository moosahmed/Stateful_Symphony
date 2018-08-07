//resource "aws_launch_configuration" "master" {
//  name_prefix                 = "master-${var.aws_region}a.masters.${var.k8s_cluster}-"
//  image_id                    = "${var.master_image_id}"
//  instance_type               = "${var.master_instance_type}"
//  key_name                    = "${var.aws_key_pair_id}"
//  iam_instance_profile        = "${var.master_iam_instance_profile_id}"
//  security_groups             = ["${var.security_group_id}"]
//  associate_public_ip_address = true
//  user_data                   = "${file("${path.root}/data/aws_launch_configuration_master-${var.aws_region}a.masters.${var.k8s_cluster}_user_data")}"
//
//  root_block_device = {
//    volume_type           = "${var.master_volume_type}"
//    volume_size           = "${var.master_volume_size}"
//    delete_on_termination = true
//  }
//
//  lifecycle = {
//    create_before_destroy = true
//  }
//
//  enable_monitoring = false
//}

data "aws_ami" "eks-worker" {
  filter {
    name   = "name"
    values = ["eks-worker-*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon
}

data "aws_region" "current" {}

locals {
  node-userdata = <<USERDATA
#!/bin/bash -xe

CA_CERTIFICATE_DIRECTORY=/etc/kubernetes/pki
CA_CERTIFICATE_FILE_PATH=$CA_CERTIFICATE_DIRECTORY/ca.crt
mkdir -p $CA_CERTIFICATE_DIRECTORY
echo "${module.eks_cluster.cluster.certificate_authority.0.data}" | base64 -d >  $CA_CERTIFICATE_FILE_PATH
INTERNAL_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
sed -i s,MASTER_ENDPOINT,${module.eks_cluster.cluster.endpoint},g /var/lib/kubelet/kubeconfig
sed -i s,CLUSTER_NAME,${var.k8s_cluster},g /var/lib/kubelet/kubeconfig
sed -i s,REGION,${data.aws_region.current.name},g /etc/systemd/system/kubelet.service
sed -i s,MAX_PODS,20,g /etc/systemd/system/kubelet.service
sed -i s,MASTER_ENDPOINT,${module.eks_cluster.cluster.endpoint},g /etc/systemd/system/kubelet.service
sed -i s,INTERNAL_IP,$INTERNAL_IP,g /etc/systemd/system/kubelet.service
DNS_CLUSTER_IP=10.100.0.10
if [[ $INTERNAL_IP == 10.* ]] ; then DNS_CLUSTER_IP=172.20.0.10; fi
sed -i s,DNS_CLUSTER_IP,$DNS_CLUSTER_IP,g /etc/systemd/system/kubelet.service
sed -i s,CERTIFICATE_AUTHORITY_FILE,$CA_CERTIFICATE_FILE_PATH,g /var/lib/kubelet/kubeconfig
sed -i s,CLIENT_CA_FILE,$CA_CERTIFICATE_FILE_PATH,g  /etc/systemd/system/kubelet.service
systemctl daemon-reload
systemctl restart kubelet
USERDATA
}
//data "template_file" "worker-config" {
//  template = "${file("${path.root}/data/worker.sh")}"
//
//  vars {
//    eks_cluster_cert_auth_0data = "${var.OUT_eks_cluster_cert_auth_0data}"
//    eks_cluster_endpoint = "${var.OUT_eks_cluster_endpoint}"
//    k8s_cluster = "${var.k8s_cluster}"
//    aws_region = "${var.aws_region}"
//  }
//}

resource "aws_launch_configuration" "nodes" {
  name_prefix                 = "nodes.${var.k8s_cluster}-"
  image_id                    = "${data.aws_ami.eks-worker.id}"
  instance_type               = "${var.node_instance_type}"
  key_name                    = "${var.aws_key_pair_id}"
  iam_instance_profile        = "${var.node_iam_instance_profile_id}"
  security_groups             = ["${var.security_group_id}"]
  associate_public_ip_address = true
  user_data_base64            = "${base64encode(local.node-userdata)}"

  //  root_block_device = {
  //    volume_type           = "${var.node_volume_type}"
  //    volume_size           = "${var.node_volume_size}"
  //    delete_on_termination = true
  //  }

  lifecycle = {
    create_before_destroy = true
  }

  //  enable_monitoring = false
}