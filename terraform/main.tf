provider "aws" {
  region = "${var.aws_region}"
}

module "iam_global" {
  source ="./global/iam/"
}

module "s3_global" {
  source = "./global/s3/"

  k8s_cluster = "${var.k8s_cluster}"
}

module "vpc_network" {
  source = "./modules/network/vpc/"

  k8s_cluster = "${var.k8s_cluster}"
}

module "igw_network" {
  source = "./modules/network/igw/"
  vpc_id = "${module.vpc_network.vpc_id}"
}

module "route_table_network" {
  source = "./modules/network/route_table/"

  vpc_id = "${module.vpc_network.vpc_id}"
  igw_id = "${module.igw_network.igw_id}"
}

module "subnet_network" {
  source = "./modules/network/subnet/"

  k8s_cluster = "${var.k8s_cluster}"

  vpc_id = "${module.vpc_network.vpc_id}"
  vpc_cidr_prefix = "${module.vpc_network.vpc_cidr_prefix}"
  aws_region = "${var.aws_region}"

  public_rt_id = "${module.route_table_network.public_rt_id}"
  private_rt_id = "${module.route_table_network.private_rt_id}"
}