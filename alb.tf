module "alb" {
  source = "modules/terraform-alb-module"

  aws_region = "${var.aws_region}"
  env = "${var.env}"
  vpc_id = "${data.aws_vpc.vpc.id}"
  internal = "false"
  it_business_unit = "accor"
  it_root_functional_area = "front"
  subnet_ids = "${data.aws_subnet_ids.subnets.ids}"
  alb_name = "demo"
  health_check_path = "/"
}

data "aws_vpc" "vpc" {
  cidr_block = "${var.vpc_cidr}"
}

data "aws_subnet_ids" "subnets" {
  vpc_id = "${data.aws_vpc.vpc.id}"
}