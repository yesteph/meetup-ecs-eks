locals {
  http_listener_arn  = "${(var.enable == true && var.https_only != true) ? element(concat(aws_alb_listener.http_listener.*.arn, list("")),0):""}"
  https_listener_arn = "${(var.enable == true && var.ssl_certificate_arn != "") ? element(concat(aws_alb_listener.https_listener.*.arn, list("")),0):""}"
  component_id       = "tf-${var.env}-${var.it_business_unit}-${var.it_root_functional_area}-${var.alb_name}"
}
