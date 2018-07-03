output "arn" {
  value = "${element(concat(aws_alb.alb.*.arn, list("")),0)}"
}

output "arn_suffix" {
  value = "${element(concat(aws_alb.alb.*.arn_suffix, list("")),0)}"
}

output "http_listener_arn" {
  value = "${local.http_listener_arn}"
}

output "https_listener_arn" {
  value = "${local.https_listener_arn}"
}

output "alb_name" {
  value = "${element(concat(aws_alb.alb.*.name, list("")),0)}"
}

output "alb_arn_arn" {
  value = "${element(concat(aws_alb.alb.*.arn, list("")),0)}"
}

output "alb_arn_suffix" {
  value = "${element(concat(aws_alb.alb.*.arn_suffix, list("")),0)}"
}

output "dns_name" {
  value = "${element(concat(aws_alb.alb.*.dns_name, list("")),0)}"
}

output "dns_alb_zone_id" {
  value = "${element(concat(aws_alb.alb.*.zone_id, list("")),0)}"
}

output "default_target_group_name" {
  value = "${element(concat(aws_alb_target_group.default_tg.*.name, list("")),0)}"
}

output "default_target_group_arn" {
  value = "${element(concat(aws_alb_target_group.default_tg.*.arn, list("")),0)}"
}

output "default_target_group_arn_suffix" {
  value = "${element(concat(aws_alb_target_group.default_tg.*.arn_suffix, list("")),0)}"
}

output "security_group" {
  value = "${element(concat(aws_security_group.alb_sg.*.id, list("")), 0)}"
}
