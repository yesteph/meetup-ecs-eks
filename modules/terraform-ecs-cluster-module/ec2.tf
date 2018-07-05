data "aws_caller_identity" "ami_owner" {}

data "aws_ami" "last_ami" {
  most_recent = true

  filter {
    name = "architecture"

    values = [
      "x86_64",
    ]
  }
}

data "template_file" "user_data" {
  template = "${file("${path.module}/templates/user-data.tpl")}"

  vars {
    ecs_profile                   = "${var.ecs_profile}"
    ecs_clustername               = "${local.cluster_name}"
  }
}

resource "aws_launch_configuration" "ecs" {
  name_prefix          = "${local.component_id}-launch-config-"
  image_id             = "ami-c91624b0"
  instance_type        = "${var.instance_type}"
  iam_instance_profile = "${aws_iam_instance_profile.ecs_container_instance_profile.arn}"
  associate_public_ip_address = "true"
  security_groups = [
    "${aws_security_group.ecs_access_sg.id}"
  ]

  ebs_optimized = "${substr(var.instance_type, 0, 2) == "t2" ? false : true}"
  user_data     = "${data.template_file.user_data.rendered}"

  lifecycle {
    create_before_destroy = true
  }

  count = "${var.ecs_profile == "cicd" ? 0:1}"
}

resource "aws_key_pair" "key1" {
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCueWuFEt1YC8r04yxL2ZF1+dImRxMpbLcQ2xk8e0+2RQJfq/VzCfGG/dmjThz7ei33IFx3hJvdDlJ1xyK1rajlrnWAI1QqJ0NA3NnoRRbWe605Vq+g/267SlXFVUJwQ7Pgd7SwEgq+EQdlRn4uAEjS36iBj09LSMzuqmzonHS+VcV/eTu81TU73OrQ6SiMFX3wNDqXzNDi+YdauGcnPSeeKnCWi51DVFHceHR3XZ5FmOi1Hz3U2ykZ00/WjaPVDsmO+RdbEcVm/clvPavWLrV1g6MthfDAL9x8a2TzksFTwBV8qcDe3jvYtcotiOgiIJZw3GX9DAvR+Gm/XTpJadGL"
}
resource "aws_launch_configuration" "ecs_with_ebs" {
  name_prefix          = "${local.component_id}-launch-config-"
  image_id             = "${var.ami_id == "false" ? data.aws_ami.last_ami.id : var.ami_id}"
  instance_type        = "${var.instance_type}"
  iam_instance_profile = "${aws_iam_instance_profile.ecs_container_instance_profile.arn}"
  key_name = "${aws_key_pair.key1.key_name}"

  security_groups = [
    "${aws_security_group.ecs_access_sg.id}"
  ]

  ebs_optimized = "${substr(var.instance_type, 0, 2) == "t2" ? false : true}"
  user_data     = "${data.template_file.user_data.rendered}"
  associate_public_ip_address = "true"
  lifecycle {
    create_before_destroy = true
  }

  // Add some room to work, do not remove this device as it is used in the Ansible ECS role.
  ebs_block_device {
    device_name = "/dev/xvdcy"
    volume_type = "gp2"
    volume_size = "${var.cicd_additionnal_ebs_size}"
  }

  count = "${var.ecs_profile == "cicd" ? 1:0}"
}

resource "aws_autoscaling_group" "ecs" {
  name                 = "${local.component_id}"
  vpc_zone_identifier  = ["${var.subnets}"]

  launch_configuration = "${var.ecs_profile != "cicd" ? join("", aws_launch_configuration.ecs.*.name) : join("", aws_launch_configuration.ecs_with_ebs.*.name)}"
  min_size             = "${var.autoscaling_min_size}"
  max_size             = "${var.autoscaling_max_size}"
  default_cooldown     = "180"                                                                                                                                   // consider 3 minutes for a newly launched instance to be Up and running

  //desired_capacity     = 1
  enabled_metrics      = ["GroupMinSize", "GroupMaxSize", "GroupDesiredCapacity", "GroupInServiceInstances", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
  termination_policies = ["OldestInstance", "ClosestToNextInstanceHour"]

  lifecycle {
    create_before_destroy = true
  }

  tags = [
    {
      key                 = "cost:it-business-unit"
      value               = "${var.it_business_unit}"
      propagate_at_launch = true
    },
    {
      key                 = "cost:cost-center"
      value               = "${var.env == "prod" ? "prod":"dev"}"
      propagate_at_launch = true
    },
    {
      key                 = "cost:environment"
      value               = "${var.env}"
      propagate_at_launch = true
    },
    {
      key                 = "cost:component"
      value               = "${var.component}"
      propagate_at_launch = true
    },
    {
      key                 = "cost:root-functional-area"
      value               = "${var.it_root_functional_area}"
      propagate_at_launch = true
    },
    {
      key                 = "environment"
      value               = "${var.env}"
      propagate_at_launch = true
    },
    {
      key                 = "component_id"
      value               = "${local.component_id}"
      propagate_at_launch = true
    },
    {
      key                 = "ecs_cluster"
      value               = "${local.cluster_name}"
      propagate_at_launch = true
    },
  ]
}


resource "aws_autoscaling_policy" "ecs_cluster_cpu_scale_out_policy" {
  name                      = "${local.component_id}-cpu-scale-out-policy"
  adjustment_type           = "ChangeInCapacity"
  autoscaling_group_name    = "${aws_autoscaling_group.ecs.name}"
  policy_type               = "StepScaling"
  metric_aggregation_type   = "Average"
  estimated_instance_warmup = 200

  step_adjustment {
    metric_interval_lower_bound = 0  // +1 between 80% and 90% CPU reservation
    metric_interval_upper_bound = 10
    scaling_adjustment          = 1
  }

  step_adjustment {
    metric_interval_lower_bound = 10 // +2 above 90% CPU reservation
    scaling_adjustment          = 2
  }

  count = "${local.checked_ec2_scaling_policy != "min_max_memory_only" ? 1:0}"
}

resource "aws_cloudwatch_metric_alarm" "ecs_cluster_cpu_scale_out_alarm" {
  alarm_name          = "${local.component_id}-cpu-scale-out-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUReservation"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "${var.scaling_cpu_max_percent}"

  dimensions {
    ClusterName = "${local.cluster_name}"
  }

  alarm_description = "This metric monitor ecs cluster cpu utilization"
  alarm_actions     = ["${aws_autoscaling_policy.ecs_cluster_cpu_scale_out_policy.arn}"]

  count = "${local.checked_ec2_scaling_policy != "min_max_memory_only" ? 1:0}"
}

resource "aws_autoscaling_policy" "ecs_cluster_memory_scale_out_policy" {
  name                      = "${local.component_id}-memory-scale-out-policy"
  adjustment_type           = "ChangeInCapacity"
  autoscaling_group_name    = "${aws_autoscaling_group.ecs.name}"
  policy_type               = "StepScaling"
  metric_aggregation_type   = "Average"
  estimated_instance_warmup = 200

  step_adjustment {
    metric_interval_lower_bound = 0  // +1 between 80% and 90% Memory reservation
    metric_interval_upper_bound = 10
    scaling_adjustment          = 1
  }

  step_adjustment {
    metric_interval_lower_bound = 10 // +2 above 90% Memory reservation
    scaling_adjustment          = 2
  }

  count = "${local.checked_ec2_scaling_policy != "min_max_cpu_only" ? 1:0}"
}

resource "aws_cloudwatch_metric_alarm" "ecs_cluster_memory_scale_out_alarm" {
  alarm_name          = "${local.component_id}-memory-scale-out-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "MemoryReservation"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "${var.scaling_memory_max_percent}"

  dimensions {
    ClusterName = "${local.cluster_name}"
  }

  alarm_description = "This metric monitor ecs cluster memory utilization"
  alarm_actions     = ["${aws_autoscaling_policy.ecs_cluster_memory_scale_out_policy.arn}"]

  count = "${local.checked_ec2_scaling_policy != "min_max_cpu_only" ? 1:0}"
}

resource "aws_autoscaling_policy" "ecs_cluster_cpu_scale_in_policy" {
  name                      = "${local.component_id}-cpu-scale-in-policy"
  adjustment_type           = "ChangeInCapacity"
  autoscaling_group_name    = "${aws_autoscaling_group.ecs.name}"
  policy_type               = "StepScaling"
  metric_aggregation_type   = "Average"
  estimated_instance_warmup = 200

  step_adjustment {
    metric_interval_upper_bound = 0
    scaling_adjustment          = -1
  }

  count = "${local.checked_ec2_scaling_policy != "min_max_memory_only" ? 1:0}"
}

resource "aws_cloudwatch_metric_alarm" "ecs_cluster_cpu_scale_in_alarm" {
  alarm_name          = "${local.component_id}-cpu-scale-in-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "5"
  metric_name         = "CPUReservation"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "${var.scaling_cpu_min_percent}"

  dimensions {
    ClusterName = "${local.cluster_name}"
  }

  alarm_description = "This metric monitor ecs cluster cpu utilization"
  alarm_actions     = ["${aws_autoscaling_policy.ecs_cluster_cpu_scale_in_policy.arn}"]

  count = "${local.checked_ec2_scaling_policy != "min_max_memory_only" ? 1:0}"
}

resource "aws_autoscaling_policy" "ecs_cluster_memory_scale_in_policy" {
  name                      = "${local.component_id}-memory-scale-in-policy"
  adjustment_type           = "ChangeInCapacity"
  autoscaling_group_name    = "${aws_autoscaling_group.ecs.name}"
  policy_type               = "StepScaling"
  metric_aggregation_type   = "Average"
  estimated_instance_warmup = 200

  step_adjustment {
    metric_interval_upper_bound = 0
    scaling_adjustment          = -1
  }

  count = "${local.checked_ec2_scaling_policy != "min_max_cpu_only" ? 1:0}"
}

resource "aws_cloudwatch_metric_alarm" "ecs_cluster_memory_scale_in_alarm" {
  alarm_name          = "${local.component_id}-memory-scale-in-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "5"
  metric_name         = "MemoryReservation"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "${var.scaling_memory_min_percent}"

  dimensions {
    ClusterName = "${local.cluster_name}"
  }

  alarm_description = "This metric monitor ecs cluster memory utilization"
  alarm_actions     = ["${aws_autoscaling_policy.ecs_cluster_memory_scale_in_policy.arn}"]

  count = "${local.checked_ec2_scaling_policy != "min_max_cpu_only" ? 1:0}"
}

resource "aws_autoscaling_schedule" "night" {
  scheduled_action_name  = "night"
  min_size               = 0
  max_size               = 0
  desired_capacity       = 0
  recurrence             = "${var.shutdown_cron_expression}"
  autoscaling_group_name = "${aws_autoscaling_group.ecs.name}"

  count = "${((var.env != "prod") && (var.env != "iso") && (! var.protect_resources) && var.auto_shutdown) ? 1 : 0}"
}

resource "aws_autoscaling_schedule" "workday" {
  scheduled_action_name  = "workday"
  min_size               = "${var.autoscaling_min_size}"
  max_size               = "${var.autoscaling_max_size}"
  desired_capacity       = "${var.autoscaling_min_size}"
  recurrence             = "${var.startup_cron_expression}"
  autoscaling_group_name = "${aws_autoscaling_group.ecs.name}"

  count = "${((var.env != "prod") && (var.env != "iso") && (! var.protect_resources) && var.auto_shutdown) ? 1 : 0}"
}
