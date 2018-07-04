variable "service_name" {
  description = "Name of the service to create (same as container name by convention)"
}

variable "env" {
  description = "The environment of this infrastructure: dev or prod."
}

variable "project" {
  description = "The project related to this cluster."
}

variable "aws_alb_target_group_service_arn" {
  description = "The ARN of the service ALB target group. For now, this is mandatory"
}

variable "ecs_cluster_name" {
  description = "The name of the ECS cluster where services must be created."
}

variable "autoscaling_min_size" {
  description = "The min size of ECS auto scaling group."
  default     = "1"
}

variable "autoscaling_max_size" {
  description = "The max size of ECS auto scaling group."
  default     = "2"
}

variable "ecs_service_iam_role_arn" {
  description = "The ARN of the ECS service role to be used."
}

variable "ecs_task_size_cpu" {
  description = "The number of CPU units used by the task."
  default     = "256"
}

variable "ecs_task_size_memory" {
  description = "The amount of memory (in MiB) used by the task (good practive is to set the double of cpu value)."
  default     = "512"
}

variable "ecs_task_iam_role_arn" {
  description = "The ARN of the ECS task role to be used."
}

variable "ecs_task_execution_role_arn" {
  description = "role of the ECS agent / docker daemon"
}

variable "container_port" {
  description = "The port to expose the task"
}

variable "alarm_notification_topic_arn" {
  description = "The ARN of the SNS topic where autoscaling alarms must be propagated."
}

variable "container_definitions_rendered" {
  description = "The json string of the container definition"
}

variable "cpu_scale_out_threshold" {
  description = "Threshold for the cpu scale out. Used or the aws_appautoscaling_policy"
  default     = "80"
}

variable "cpu_scale_out_evaluation_periods" {
  description = "Number of period needed to fire the aws_cloudwatch_metric_alarm"
  default     = "2"
}

variable "scaling_out_adjustment" {
  description = "Number of task added for one scale out event"
  default     = 1
}

variable "cpu_scale_in_threshold" {
  description = "Threshold for the cpu scale in. Used or the aws_appautoscaling_policy"
  default     = "25"
}

variable "cpu_scale_in_evaluation_periods" {
  description = "Number of period needed to fire the aws_cloudwatch_metric_alarm"
  default     = "3"
}

variable "scaling_in_adjustment" {
  description = "Number of task removed for one scale in event"
  default     = -1
}

variable "health_check_grace_period" {
  description = "Seconds to ignore failing load balancer health checks on newly instantiated tasks to prevent premature shutdown"
  default     = 0
}

variable "it_root_functional_area" {
  description = "IT management: classify the area related to this LB."
}

variable "volume_list" {
  type = "list"
  default = []
}
variable "subnets" {
  type = "list"
}

variable "security_group" {

}