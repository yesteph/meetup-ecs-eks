resource "aws_cloudwatch_metric_alarm" "cpu_scale_out" {
  alarm_name          = "tf-${var.env}-${var.project}-${var.it_root_functional_area}-${var.service_name}-cpu-scale-out"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "${var.cpu_scale_out_evaluation_periods}"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "${var.cpu_scale_out_threshold}"

  dimensions {
    ClusterName = "${data.aws_ecs_cluster.ecs_cluster.cluster_name}"
    ServiceName = "${aws_ecs_service.service.name}"
  }

  alarm_description = "This metric monitor cpu utilization for ECS service ${aws_ecs_service.service.name}"
  alarm_actions     = ["${aws_appautoscaling_policy.scale_out.arn}"]

  depends_on = ["aws_appautoscaling_policy.scale_out"]
}

resource "aws_cloudwatch_metric_alarm" "cpu_scale_in" {
  alarm_name          = "tf-${var.env}-${var.project}-${var.it_root_functional_area}-${var.service_name}-cpu-scale-in"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "${var.cpu_scale_in_evaluation_periods}"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "${var.cpu_scale_in_threshold}"

  dimensions {
    ClusterName = "${data.aws_ecs_cluster.ecs_cluster.cluster_name}"
    ServiceName = "${aws_ecs_service.service.name}"
  }

  alarm_description = "This metric monitor cpu utilization for ECS service ${aws_ecs_service.service.name}"
  alarm_actions     = ["${aws_appautoscaling_policy.scale_in.arn}"]

  depends_on = ["aws_appautoscaling_policy.scale_in"]
}

resource "aws_cloudwatch_metric_alarm" "ecs_task_max_size_alarm" {
  alarm_name          = "tf-${var.env}-${var.project}-${var.it_root_functional_area}-${var.service_name}-max-size-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "5"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "SampleCount"
  threshold           = "${ceil(aws_appautoscaling_target.scale_tgt.max_capacity * 0.9)}"

  dimensions {
    ClusterName = "${data.aws_ecs_cluster.ecs_cluster.cluster_name}"
    ServiceName = "${aws_ecs_service.service.name}"
  }

  alarm_description = "This metric monitor capacity versus max size for autoscaling of ${aws_appautoscaling_target.scale_tgt.id}"
  alarm_actions     = ["${var.alarm_notification_topic_arn}"]
  depends_on        = ["aws_ecs_service.service"]

  count = "${var.alarm_notification_topic_arn != "" ? 1:0}"
}
