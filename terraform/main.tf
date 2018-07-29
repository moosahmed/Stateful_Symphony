provider "aws" {
  region = "${var.aws_region}"
}

module "vpc_network" {
  source = "./modules/network/vpc/"
}

module "igw_network" {
  source = "./modules/network/igw/"
  vpc_id = "${module.vpc_network.vpc_id}"
}