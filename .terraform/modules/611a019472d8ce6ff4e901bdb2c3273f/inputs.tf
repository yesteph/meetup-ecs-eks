variable "aws_region" {
  description = "The AWS region where resources must be created."
}

variable "env" {
  description = "String prefix to identify the platform."
}

variable "vpc_id" {
  description = "The VPC id where micro-service must be deployed."
}

variable "subnet_ids" {
  type        = "list"
  description = "The list of subnet ids to instanciate application load balancer."
}

variable "internal" {
  description = "Indicates the type of ALB : true for an internal ALB ; false for a public ALB."
}

variable "additional_security_groups_to_add" {
  description = "The list of security group IDs that must be added to this ALB. Usefull to allow interconnection between the ALB and an other component (ex: ECS cluster)."
  type        = "list"
  default     = []
}

variable "it_business_unit" {
  type        = "string"
  description = "IT management: classify the BU related to these components."
}

variable "it_root_functional_area" {
  description = "IT management: classify the area related to these components."
  default     = "infra"
}

variable "alb_name" {
  description = "The name of the Application Load Balancer."
}

variable "ips_to_allow" {
  type        = "list"
  description = "The list of cidr allowed to call the load balancer. Complementary with security_groups_to_allow."
  default     = []
}

variable "security_groups_to_allow" {
  type        = "list"
  description = "The list of security group allowed to call the load balancer. Complementary with ips_to_allow."
  default     = []
}

variable "health_check_path" {
  description = "Health check for the default target group."
}

variable "health_check_unhealthy_threshold" {
  description = "The number of failed health checks to consider a node unhealthy."
  default     = "4"
}

variable "health_check_healthy_threshold" {
  description = "The number of success health checks to consider a node healthy."
  default     = "3"
}

variable "health_check_timeout" {
  description = "The timeout in seconds to consider a health check timed out!"
  default     = "5"
}

variable "health_check_matcher" {
  description = "The HTTP codes to use when checking for a successful response. See https://www.terraform.io/docs/providers/aws/r/lb_target_group.html#matcher"
  default     = "200"
}

variable "health_check_interval" {
  description = "The interval between 2 successive health checks."
  default     = "30"
}

variable "enable" {
  default     = "true"
  description = "Boolean which indicates if resources must be really provisionned."
}

variable "ssl_certificate_arn" {
  default     = ""
  description = "If it is a valid ARN, HTTPS listener (tcp 443) is enabled."
}

variable "ssl_security_policy" {
  default     = "ELBSecurityPolicy-2016-08"
  description = "The SSL policy applied on the HTTPS listener of the ALB."
}

variable "default_target_group_port" {
  description = "The port on which targets in the default target group receive traffic, unless overridden when registering a specific target"
  default     = "80"
}

variable "https_only" {
  description = "Boolean to indicate if the load-balancer must serve HTTPS only. Suppose valid ssl_certificate_arn."
  default     = "false"
}
