data "aws_vpc" "vpc" {
  cidr_block = "${var.vpc_cidr}"
}

data "aws_subnet_ids" "subnets" {
  vpc_id = "${data.aws_vpc.vpc.id}"
}