resource "aws_appautoscaling_target" "scale_tgt" {
  service_namespace  = "ecs"
  resource_id        = "service/${data.aws_ecs_cluster.ecs_cluster.cluster_name}/${aws_ecs_service.service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = "${var.autoscaling_min_size}"
  max_capacity       = "${var.autoscaling_max_size}"
  depends_on         = ["aws_ecs_service.service"]
}

resource "aws_appautoscaling_policy" "scale_in" {
  name               = "tf-${aws_appautoscaling_target.scale_tgt.id}-scale-in"
  service_namespace  = "ecs"
  resource_id        = "service/${data.aws_ecs_cluster.ecs_cluster.cluster_name}/${aws_ecs_service.service.name}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = "${var.scaling_in_adjustment}"
    }
  }

  depends_on = ["aws_appautoscaling_target.scale_tgt"]
}

resource "aws_appautoscaling_policy" "scale_out" {
  name               = "tf-${aws_appautoscaling_target.scale_tgt.id}-scale-out"
  service_namespace  = "ecs"
  resource_id        = "service/${data.aws_ecs_cluster.ecs_cluster.cluster_name}/${aws_ecs_service.service.name}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 120
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = "${var.scaling_out_adjustment}"
    }
  }

  depends_on = ["aws_appautoscaling_target.scale_tgt"]
}
