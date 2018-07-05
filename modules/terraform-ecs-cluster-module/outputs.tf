output "ecs_cluster_security_group_id" {
  value       = "${aws_security_group.ecs_access_sg.id}"
  description = "The ID of the security group of the ECS cluster."
}

output "ecs_cluster_name" {
  value = "${local.cluster_name}"
}

output "ecs_cluster_arn" {
  value = "${local.ecs_cluster_arn}"
}

output "iam_ecs_service_role_arn" {
  value = "${aws_iam_role.ecs_container_service_role.arn}"
}

output "autoscaling_group_name" {
  description = "The name of the created autoscaling group"
  value       = "${aws_autoscaling_group.ecs.name}"
}

output "ami_id" {
  description = "The name of the used AMI"
  value       = "${var.ami_id == "false" ? data.aws_ami.last_ami.id : var.ami_id}"
}

output "user_data_md5" {
  description = "The MD5 of the user-data template. To be used to link an AMI"
  value       = "${local.user_data_md5}"
}

output "external_ecs_access_security_group_id" {
  value       = "${aws_security_group.external_ecs_access_sg.id}"
  description = "The ID of the security group to be used to access the ECS cluster."
}

output "docker_directories" {
  description = "The list of created docker directories for shared mounts."
  value       = "${data.template_file.docker_directories_outputs.*.rendered}"
}
