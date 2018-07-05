resource "aws_cloudwatch_log_group" "ecs_agent_log" {
  name              = "/ec2/${var.env}/${local.component_id}/ecs/ecs-agent.log"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "docker_log" {
  name              = "/ec2/${var.env}/${local.component_id}/docker"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "ecs_audit_log" {
  name              = "/ec2/${var.env}/${local.component_id}/ecs/audit.log"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "ecs_init_log" {
  name              = "/ec2/${var.env}/${local.component_id}/ecs/ecs-init.log"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_metric_filter" "OOM" {
  name           = "${local.component_id}-OOM"
  pattern        = "died due to OOM"
  log_group_name = "${aws_cloudwatch_log_group.ecs_agent_log.name}"

  metric_transformation {
    namespace = "${local.component_id}-logmetrics"
    name      = "OOM"
    value     = "1"
  }
}
