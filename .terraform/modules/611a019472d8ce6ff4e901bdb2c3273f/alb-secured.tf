resource "aws_alb_listener" "https_listener" {
  load_balancer_arn = "${aws_alb.alb.arn}"
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "${var.ssl_security_policy}"
  certificate_arn   = "${var.ssl_certificate_arn}"

  default_action {
    target_group_arn = "${aws_alb_target_group.default_tg.arn}"
    type             = "forward"
  }

  count = "${(var.enable == true && var.ssl_certificate_arn != "") ? 1 : 0}"
}
