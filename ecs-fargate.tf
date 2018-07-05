resource "aws_cloudwatch_log_group" "application" {
  name              = "/ecs/${var.env}/demo/front"
  retention_in_days = 7
}

data "aws_iam_policy_document" "execution_role_policy" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"

      identifiers = [
        "ecs-tasks.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_role" "ecs_fargate_execution_role" {
  name               = "tf-${var.env}-fargate"
  assume_role_policy = "${data.aws_iam_policy_document.execution_role_policy.json}"
}

resource "aws_iam_role_policy_attachment" "ecs_fargate_task_role_policy_attach" {
  role       = "${aws_iam_role.ecs_fargate_execution_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


data template_file "fargate" {
  template = "${file("${path.module}/templates/fargate.tpl")}"

  vars {
    container_name        = "front"
    container_port        = "80"
    docker_tag            = "${var.docker_tag}"
    docker_cpu            = "${var.ecs_task_size_cpu}"
    docker_memory         = "${var.ecs_task_size_memory}"
    aws_region            = "${var.aws_region}"
    cloudwatch_group_name = "${aws_cloudwatch_log_group.application.name}"
    environment           = "${var.env}"
  }
}

resource "aws_security_group" "fargate" {
  name = "tf-fargate"
  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    protocol = "tcp"
    to_port = 65535
    cidr_blocks = ["0.0.0.0/0"]
  }
  vpc_id = "${data.aws_vpc.vpc.id}"
}

module "fargate" {
  source = "modules/terraform-ecs-fargate-service-module"
  env = "demo"

  project = "fargate"
  ecs_cluster_name = "${aws_ecs_cluster.meetup.name}"
  container_port = "80"
  aws_alb_target_group_service_arn = "${module.alb-fargate.default_target_group_arn}"

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