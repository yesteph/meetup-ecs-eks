## Description

This module creates an EC2 service for an ECS cluster.

The provisioned elements are :
* An ECS service registered to a target group (loadbalancer)
* auto scaling policy to vary the number of instance for the ECS service 
* cloudwatch alarms

### Cloudwatch alarms

A "max-size-alarm" is created, based on 90% of the max size of the auto scaling group.

### auto scaling target

We automatically scale the number of ecs task

#### scale-in / scale-out policies

2 policies are defined :
* CPU based scale-out
* CPU base scale-in

CPU is based on the Utilization Average for all instances of the ECS service.

### ECS Service

We create an ECS service, spread accross availability zone and instance of the cluster
Each service have a loadbalancer configuration mandatory

## Requirements
Terraform AWS provider with at least at version **1.7.0**.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| alarm_notification_topic_arn | The ARN of the SNS topic where autoscaling alarms must be propagated. | string | - | yes |
| autoscaling_max_size | The max size of ECS auto scaling group. | string | `2` | no |
| autoscaling_min_size | The min size of ECS auto scaling group. | string | `1` | no |
| aws_alb_target_group_service_arn | The ARN of the service ALB target group. For now, this is mandatory | string | - | yes |
| aws_region | The AWS region used. | string | - | yes |
| container_definitions_rendered | The json string of the container definition | string | - | yes |
| container_port | The port to expose the task | string | - | yes |
| cpu_scale_in_evaluation_periods | Number of period needed to fire the aws_cloudwatch_metric_alarm | string | `3` | no |
| cpu_scale_in_threshold | Threshold for the cpu scale in. Used or the aws_appautoscaling_policy | string | `25` | no |
| cpu_scale_out_evaluation_periods | Number of period needed to fire the aws_cloudwatch_metric_alarm | string | `2` | no |
| cpu_scale_out_threshold | Threshold for the cpu scale out. Used or the aws_appautoscaling_policy | string | `80` | no |
| ecs_cluster_name | The name of the ECS cluster where services must be created. | string | - | yes |
| ecs_service_iam_role_arn | The ARN of the ECS service role to be used. | string | - | yes |
| ecs_task_iam_role_arn | The ARN of the ECS task role to be used. | string | - | yes |
| ecs_task_size_cpu | The number of CPU units used by the task. | string | `128` | no |
| ecs_task_size_memory | The amount of memory (in MiB) used by the task (good practive is to set the double of cpu value). | string | `256` | no |
| env | The environment of this infrastructure: dev or prod. | string | - | yes |
| health_check_grace_period | Seconds to ignore failing load balancer health checks on newly instantiated tasks to prevent premature shutdown | string | `0` | no |
| it_root_functional_area | IT management: classify the area related to this LB. | string | - | yes |
| project | The project related to this cluster. | string | - | yes |
| scaling_in_adjustment | Number of task removed for one scale in event | string | `-1` | no |
| scaling_out_adjustment | Number of task added for one scale out event | string | `1` | no |
| service_name | Name of the service to create (same as container name by convention) | string | - | yes |
