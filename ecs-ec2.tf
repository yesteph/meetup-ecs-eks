

module "ec2" {
  source = "modules/terraform-ecs-ec2-service-module"
  env = "demo"

  project = "ec2"
  ecs_cluster_name = "${aws_ecs_cluster.meetup.name}"
  container_port = "80"
  aws_alb_target_group_service_arn = "${module.alb-ec2.default_target_group_arn}"

  it_root_functional_area = "front"
  alarm_notification_topic_arn = ""
  service_name = "front"
  ecs_service_iam_role_arn = ""
  ecs_task_iam_role_arn = ""
  ecs_task_execution_role_arn = "${aws_iam_role.ecs_fargate_execution_role.arn}"
  container_definitions_rendered = "${data.template_file.fargate.rendered}"
  subnets = "${data.aws_subnet_ids.subnets.ids}"
  security_group = "${aws_security_group.fargate.id}"
}