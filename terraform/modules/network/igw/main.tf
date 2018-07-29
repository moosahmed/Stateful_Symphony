## IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = "${var.vpc_id}"

  tags {
    Name = "${terraform.workspace}-igw"
    Environment = "${terraform.workspace}"
  }
}