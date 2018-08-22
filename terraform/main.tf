provider "http" {}

provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.aws_region}"
}

provider "kubernetes" {
  host                   = "${module.eks_cluster.eks_cluster_endpoint}"
  cluster_ca_certificate = "${base64decode(module.eks_cluster.eks_cluster_cert_auth_0data)}"
  token                  = "${data.external.aws-iam-authenticator.result.token}"
  load_config_file       = false
}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {}

data "http" "workstation-external-ip" {
  url = "http://ipv4.icanhazip.com"
}

data "external" "aws-iam-authenticator" {
  program = ["bash", "${path.root}/data/authenticator.sh"]

  query {
    cluster_name = "${terraform.workspace}-${var.k8s_cluster}"
  }
}

locals {
  workstation-external-cidr = "${chomp(data.http.workstation-external-ip.body)}/32"
}

module "iam_global" {
  source      = "./global/iam/"

  k8s_cluster = "${var.k8s_cluster}"
}

module "vpc_network" {
  source      = "./modules/network/vpc/"

  k8s_cluster = "${var.k8s_cluster}"
}

module "igw_network" {
  source      = "./modules/network/igw/"

  k8s_cluster = "${var.k8s_cluster}"
  vpc_id      = "${module.vpc_network.vpc_id}"
}

module "security_groups" {
  source                    = "./modules/network/security_group/"

  k8s_cluster               = "${var.k8s_cluster}"
  vpc_id                    = "${module.vpc_network.vpc_id}"
  workstation-external-cidr = "${local.workstation-external-cidr}"
}

module "route_table_network" {
  source      = "./modules/network/route_table/"

  k8s_cluster = "${var.k8s_cluster}"
  vpc_id      = "${module.vpc_network.vpc_id}"
  igw_id      = "${module.igw_network.igw_id}"
}

module "launch_configuration" {
  source                       = "./modules/servers/launch_configuration/"

  aws_region                   = "${var.aws_region}"
  k8s_cluster                  = "${var.k8s_cluster}"
  aws_key_pair_id              = "${module.iam_global.aws_key_pair_id}"

  security_group_id            = "${module.security_groups.node_sg_id}"

  node_instance_type           = "m4.large"
  node_iam_instance_profile_id = "${module.iam_global.node_iam_instance_profile_id}"

  eks_cluster_cert_auth_0data  = "${module.eks_cluster.eks_cluster_cert_auth_0data}"
  eks_cluster_endpoint         = "${module.eks_cluster.eks_cluster_endpoint}"
}

module "eks_cluster" {
  source                = "./modules/eks/cluster/"

  k8s_cluster           = "${var.k8s_cluster}"
  cluster_iam_role_name = "${module.iam_global.iam_role_master_name}"
  cluster_iam_role_arn  = "${module.iam_global.iam_role_master_arn}"

  vpc_id                = "${module.vpc_network.vpc_id}"
  vpc_cidr_prefix       = "${module.vpc_network.vpc_cidr_prefix}"
  cluster_sg_id         = "${module.security_groups.cluster_sg_id}"
  public_rt_id          = "${module.route_table_network.public_rt_id}"

  node_launch_config_id = "${module.launch_configuration.node_launch_config_id}"
}

module "k8s_config_map" {
  source            = "./modules/k8s/config_map"

  node_iam_role_arn = "${module.iam_global.iam_role_node_arn}"
}

module "k8s_c7a" {
  source = "./modules/k8s/c7a"

  k8s_cluster = "${var.k8s_cluster}"
  eks_cluster_cert_auth_0data = "${module.eks_cluster.eks_cluster_cert_auth_0data}"
  eks_cluster_endpoint = "${module.eks_cluster.eks_cluster_endpoint}"
}

module "k8s_spark" {
  source = "./modules/k8s/spark"
  spark_user_name = "symph"

  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"

  c7a-ips_id = "${module.k8s_c7a.c7a-ips_id}"
  s3_bucket_url = "${var.s3_bucket_url}"
}

module "k8s_njs" {
  source = "./modules/k8s/nodejs"
  c7a-ips_id = "${module.k8s_c7a.c7a-ips_id}"
  gmaps_api_key = "${var.gmaps_api_key}"
}