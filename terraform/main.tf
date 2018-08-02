provider "aws" {
  region = "${var.aws_region}"
}

module "iam_global" {
  source ="./global/iam/"

  k8s_cluster = "${var.k8s_cluster}"
}

module "s3_global" {
  source      = "./global/s3/"

  k8s_cluster = "${var.k8s_cluster}"
  bucket_name = "${var.s3_bucket_name}"
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
  source      = "./modules/network/security_group/"

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

module "launch_config" {
  source = "./modules/servers/launch_config/"

  aws_region = "${var.aws_region}"
  k8s_cluster = "${var.k8s_cluster}"
  aws_key_pair_id = ""

  security_group_id = "${module.security_groups.cluster_sg_id}"

  master_image_id = "ami-4bfe6f33"
  master_instance_type = "t2.micro"
  master_iam_instance_profile_id = ""
  master_volume_type = "gp2"
  master_volume_size = 64

  node_image_id = "ami-4bfe6f33"
  node_instance_type = "t2.micro"
  node_iam_instance_profile_id = ""
  node_volume_type = "gp2"
  node_volume_size = 128
}

module "autoscaling_group" {
  source                  = "./modules/servers/asg/"

  aws_region              = "${var.aws_region}"
  k8s_cluster             = "${var.k8s_cluster}"

  public_subnet_id        = "${module.subnet_network.public_subnet_id}"
  master_launch_config_id = "${module.launch_config.master_launch_config_id}"
  node_launch_config_id   = "${module.launch_config.node_launch_config_id}"
}

module "ebs_volume" {
  source = "./modules/volume/ebs/"

  aws_region              = "${var.aws_region}"
  k8s_cluster             = "${var.k8s_cluster}"
}