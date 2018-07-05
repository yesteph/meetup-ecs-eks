variable "ecs_profile" {
  default     = "standard"
  description = "The ECS profile to use, must be defined in ansible-vsct-ecs."
}

variable "cluster_name" {
  description = "The name of the ECS cluster."
}

variable "env" {
  description = "The environment of this infrastructure: dev or prod."
}

variable "it_business_unit" {
  type        = "string"
  description = "IT management: classify the BU related to these components."
}

variable "it_root_functional_area" {
  description = "IT management: classify the area related to these components."
  default     = "infra"
}

variable "component" {
  description = "The name of the component."
  default     = "ecs"
}

variable "instance_type" {
  default = "t2.small"
}

variable "vpc_id" {
  description = "The VPC where the cluster must be created."
}

variable "alarm_notification_topic_arn" {
  description = "The ARN where notifications must be sent."
}

variable "enable_alarm_creation" {
  description = "A boolean to indicate if the alarms must be created."
  default     = "true"
}

variable "subnets" {
  type        = "list"
  description = "The list of subnet ids used to create the ECS cluster."
}

variable "aws_region" {
  description = "The AWS region used."
}

variable "autoscaling_max_size" {
  description = "The max number of EC2 instances in the ECS cluster."
}

variable "autoscaling_min_size" {
  description = "The min number of EC2 instances in the ECS cluster."
}

variable "shutdown_cron_expression" {
  description = "The UTC cron expression to shutdown (min=max=desired = 0) the cluster."
  default     = "0 18 * * *"
}

variable "startup_cron_expression" {
  description = "The UTC cron expression to start (min=autoscaling_min_size, max=autoscaling_max_size) the cluster."
  default     = "0 7 * * 1-5"
}

variable "auto_shutdown" {
  description = "Boolean to indicate if the cluster must be shutdown. Bypass to false if env is prod or iso or if protect_resources is set!"
  default     = true
}

variable "ami_id" {
  default     = "false"
  description = "Default is \"false\", then last ecs-* is used. If different from \"false\", use the provided ami_id."
}

variable "ami_lifecycle_tag" {
  default     = "validated"
  description = "The value of the lifecycle tag to select the most recent ami."
}

variable "ec2_scaling_policy" {
  default     = "min_max_cpu_only"
  description = "Determine the policy used to auto scale the EC2 instances in the cluster. Possible values are: min_max_cpu_and_memory | min_max_cpu_only | min_max_memory_only."
}

variable "__ec2_scaling_policy_format" {
  type        = "map"
  description = "Internal variable to validate ec2_scaling_policy"

  default = {
    "min_max_cpu_and_memory" = "min_max_cpu_and_memory"
    "min_max_cpu_only"       = "min_max_cpu_only"
    "min_max_memory_only"    = "min_max_memory_only"
  }
}

variable "scaling_cpu_min_percent" {
  description = "The minimum CPU reservation threshold to remove an instance."
  default     = "50"
}

variable "scaling_cpu_max_percent" {
  description = "The maximum CPU reservation threshold to add an instance."
  default     = "80"
}

variable "scaling_memory_min_percent" {
  description = "The minimum MEMORY reservation threshold to remove an instance."
  default     = "50"
}

variable "scaling_memory_max_percent" {
  description = "The maximum MEMORY reservation threshold to add an instance."
  default     = "75"
}

variable "ecs_heartbeat_timeout" {
  description = "The timeout in seconds to let an ECS instance in 'draining' state. If some ECS tasks are still running after this timeout, they will stopped"
  default     = "600"
}

variable "filter_ami_on_user_data_md5" {
  default     = "true"
  description = "Boolean to indicate if the AMI to be used will be filter on module user-data MD5."
}

variable "cicd_additionnal_ebs_size" {
  description = "Additional EBS block device size for a 'cicd' ecs_profile"
  default     = 50
}

variable "protect_resources" {
  description = "Boolean to indicate if resources must be protected against destruction."
}

variable "efs_security_group_id" {
  description = "The security group of the EFS mount target the prometheus VM will access."
  default     = ""
}

variable "nfs_dns_name_for_storage" {
  description = "The DNS endpoint of the NFS server to store prometheus data. Form must be DNS_NAME:DIR. Will use local disk if empty."
  default     = ""
}

variable "nfs_dir" {
  description = "The local directory where NFS is mounted. Only used if nfs_dns_name_for_storage is not empty"
  default     = "/nfs"
}

variable "docker_users_and_groups" {
  type        = "list"
  default     = []
  description = "The list of system users/group/UIDs to be created for shared mounts with docker containers. Each entry must be a map with the following keys : user/group/uid"
}

variable "docker_directories" {
  type        = "list"
  default     = []
  description = "The list of directories to be created for shared mounts with docker containers. Each entry must be a map with the following keys : directory_name/directory_base_location/user/group"
}
