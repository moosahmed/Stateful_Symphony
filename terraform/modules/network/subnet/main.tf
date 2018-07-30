## Public Subnet
resource "aws_subnet" "public-subnet" {
  vpc_id = "${var.vpc_id}"
  cidr_block = "${var.vpc_cidr_prefix}.0.0/19"
  availability_zone = "${var.aws_region}a"

  tags {
    Name = "${terraform.workspace}-public-subnet"
    Environment = "${terraform.workspace}"
    Type = "public"
  }
}

## Private Subnet
resource "aws_subnet" "private-subnet" {
  vpc_id = "${var.vpc_id}"
  cidr_block = "${var.vpc_cidr_prefix}.128.0/20"
  availability_zone = "${var.aws_region}a"

  tags {
    Name = "${terraform.workspace}-private-subnet"
    Environment = "${terraform.workspace}"
    Type = "private"
  }
}
## Route table associations
resource "aws_route_table_association" "public-subnet" {

  subnet_id = "${aws_subnet.public-subnet.id}"
  route_table_id = "${var.public_rt_id}"
}

resource "aws_route_table_association" "private-subnet" {

  subnet_id = "${aws_subnet.private-subnet.id}"
  route_table_id = "${var.private_rt_id}"
}