provider "aws" {
  region = "${var.aws_region}"
}

module "iam_global" {
  source ="./global/iam/"
}

module "s3_global" {
  source      = "./global/s3/"

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

module "route_table_network" {
  source      = "./modules/network/route_table/"

  k8s_cluster = "${var.k8s_cluster}"
  vpc_id      = "${module.vpc_network.vpc_id}"
  igw_id      = "${module.igw_network.igw_id}"
}

module "subnet_network" {
  source          = "./modules/network/subnet/"

  aws_region      = "${var.aws_region}"
  k8s_cluster     = "${var.k8s_cluster}"
  vpc_id          = "${module.vpc_network.vpc_id}"
  vpc_cidr_prefix = "${module.vpc_network.vpc_cidr_prefix}"

  public_rt_id    = "${module.route_table_network.public_rt_id}"
  private_rt_id   = "${module.route_table_network.private_rt_id}"
}

module "auto_scaling_group" {
  source           = "./modules/servers/asg/"

  aws_region       = "${var.aws_region}"
  k8s_cluster      = "${var.k8s_cluster}"
  public_subnet_id = "${module.subnet_network.public_subnet_id}"
  master_lc_id     = ""
  node_lc_id       = ""
}