resource "aws_alb" "alb" {
  internal        = "${var.internal}"
  security_groups = ["${concat(var.additional_security_groups_to_add, list(aws_security_group.alb_sg.id))}"]
  subnets         = ["${var.subnet_ids}"]

  enable_deletion_protection = "${var.env == "prod" ? true : false}"

  tags {
    "name"                      = "${local.component_id}"
    "cost:root-functional-area" = "${var.it_root_functional_area}"
    "cost:it-business-unit"     = "${var.it_business_unit}"
    "cost:cost-center"          = "${var.env == "prod" ? "prod":"dev"}"
    "cost:environment"          = "${var.env}"
    "cost:component"            = "lb-${var.internal == 1?"private":"public"}"
    "environment"               = "${var.env}"
  }

  count = "${var.enable == true ? 1 : 0}"
}

resource "aws_alb_target_group" "default_tg" {
  port     = "${var.default_target_group_port}"
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  deregistration_delay = 30 # 30 seconds draining

  lifecycle {
    create_before_destroy = true
  }

  health_check {
    path                = "${var.health_check_path}"
    matcher             = "${var.health_check_matcher}"
    protocol            = "HTTP"
    unhealthy_threshold = "${var.health_check_unhealthy_threshold}"
    healthy_threshold   = "${var.health_check_healthy_threshold}"
    timeout             = "${var.health_check_timeout}"
    interval            = "${var.health_check_interval}"
  }

  tags {
    "name"                      = "tf-${var.env}-${var.it_business_unit}-${var.it_root_functional_area}-${var.alb_name}-def"
    "default-group"             = "true"
    "cost:root-functional-area" = "${var.it_root_functional_area}"
    "cost:it-business-unit"     = "${var.it_business_unit}"
    "cost:cost-center"          = "${var.env == "prod" ? "prod":"dev"}"
    "cost:environment"          = "${var.env}"
    "cost:component"            = "lb-${var.internal == 1?"private":"public"}"
    "environment"               = "${var.env}"
  }

  count = "${var.enable == true ? 1 : 0}"
}

resource "aws_alb_listener" "http_listener" {
  load_balancer_arn = "${aws_alb.alb.arn}"
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.default_tg.arn}"
    type             = "forward"
  }

  count = "${(var.enable == true && var.https_only != true) ? 1 : 0}"
}
