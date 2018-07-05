module "alb-ec2" {
  source = "modules/terraform-alb-module"

  aws_region = "${var.aws_region}"
  env = "${var.env}"
  vpc_id = "${data.aws_vpc.vpc.id}"
  internal = "false"
  it_business_unit = "accor"
  it_root_functional_area = "fargate"
  subnet_ids = "${data.aws_subnet_ids.subnets.ids}"
  alb_name = "ec2"
  health_check_path = "/"
}

