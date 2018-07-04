variable "env" {}
variable "aws_region" {}
variable "vpc_cidr" {}

variable "ecs_task_size_cpu" {
  description = "The number of CPU units used by the task."
  default     = "256"
}

variable "ecs_task_size_memory" {
  description = "The amount of memory (in MiB) used by the task (good practive is to set the double of cpu value)."
  default     = "512"
}
variable "docker_tag" {
  type = "string"
  description = "Docker tag of the component"
}