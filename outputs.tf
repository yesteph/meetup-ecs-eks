output "dns-fargate" {
  value = "${module.alb-fargate.dns_name}"
}

output "dns-ec2" {
  value = "${module.alb-ec2.dns_name}"
}