resource "aws_security_group" "alb_sg" {
  name        = "${local.component_id}-alb"
  description = "Allow inbound traffic to ALB ${var.alb_name}"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${local.component_id}-alb"
  }

  lifecycle {
    create_before_destroy = true
  }

  count = "${var.enable == true ? 1 : 0}"
}

resource "aws_security_group_rule" "allow_cidrs_to_alb_http" {
  security_group_id = "${aws_security_group.alb_sg.id}"

  type = "ingress"

  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["${var.ips_to_allow}"]

  count = "${length(var.ips_to_allow) != 0 && var.enable == true ?1:0}"
}

resource "aws_security_group_rule" "allow_cidrs_to_alb_https" {
  security_group_id = "${aws_security_group.alb_sg.id}"

  type = "ingress"

  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["${var.ips_to_allow}"]

  count = "${length(var.ips_to_allow) != 0 && var.enable == true ?1:0}"
}

resource "aws_security_group_rule" "allow_sg_to_alb_http" {
  security_group_id = "${aws_security_group.alb_sg.id}"

  type = "ingress"

  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = "${element(var.security_groups_to_allow, count.index)}"

  count = "${length(var.security_groups_to_allow) != 0 && var.enable == true ?1:0}"
}

resource "aws_security_group_rule" "allow_sg_to_alb_https" {
  security_group_id = "${aws_security_group.alb_sg.id}"

  type = "ingress"

  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = "${element(var.security_groups_to_allow, count.index)}"

  count = "${length(var.security_groups_to_allow) != 0 && var.enable == true ?1:0}"
}
