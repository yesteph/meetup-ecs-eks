## Description

This module creates an application load balancer.

The provisioned elements are :
* an ALB, default target group, a listener on port 80
* if a certificate ARN is specified, a secured listener on port 443
* cloudwatch alarms
* DNS CNAME
* security group

## ALB resources

In addition of the ALB, the following components are provisioned:
* a default target group, which sends traffic to backends on **default_target_group**
* an HTTP listener on port 80 if **https_only** is not **true**
* an HTTPS listener on port 443 if **ssl_certificate_arn** is not empty

Tags are set on the ALB and the default target group:
* name
* default-group
* cost:root-functional-area
* cost:it-business-unit
* cost:cost-center
* cost:environment
* cost:component
* environment

## Cloudwatch alarms

An alarm based on the number of HTTP 500 errors is configured.

## DNS

A DNS alias on  "${var.env}-${var.project}-${var.it_root_functional_area}-${var.alb_name}-alb.${var.dns_zone_domain}" is created.

## Security group

A security group to allow http and https on the ALB is created.
Sources are ${var.ips_to_allow] and ${var.security_groups_to_allow}.

The parameter additional_security_groups_to_add contains a list of security group worn by the load balancer.
This can be used to allow the load-balancer to communicate with external component like ECS cluster.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| additional_security_groups_to_add | The list of security group IDs that must be added to this ALB. Usefull to allow interconnection between the ALB and an other component (ex: ECS cluster). | list | `<list>` | no |
| alb_name | The name of the Application Load Balancer. | string | - | yes |
| aws_region | The AWS region where resources must be created. | string | - | yes |
| default_target_group_port | The port on which targets in the default target group receive traffic, unless overridden when registering a specific target | string | `80` | no |
| dns_zone_domain | DNS zone domain suffix. Must match dns_zone_id. | string | - | yes |
| dns_zone_id | DNS zone id to create DNS record alias. | string | - | yes |
| enable | Boolean which indicates if resources must be really provisionned. | string | `true` | no |
| env | String prefix to identify the platform. | string | - | yes |
| health_check_healthy_threshold | The number of success health checks to consider a node healthy. | string | `3` | no |
| health_check_interval | The interval between 2 successive health checks. | string | `30` | no |
| health_check_matcher | The HTTP codes to use when checking for a successful response. See https://www.terraform.io/docs/providers/aws/r/lb_target_group.html#matcher | string | `200` | no |
| health_check_path | Health check for the default target group. | string | - | yes |
| health_check_timeout | The timeout in seconds to consider a health check timed out! | string | `5` | no |
| health_check_unhealthy_threshold | The number of failed health checks to consider a node unhealthy. | string | `4` | no |
| https_only | Boolean to indicate if the load-balancer must serve HTTPS only. Suppose valid ssl_certificate_arn. | string | `false` | no |
| internal | Indicates the type of ALB : true for an internal ALB ; false for a public ALB. | string | - | yes |
| ips_to_allow | The list of cidr allowed to call the load balancer. Complementary with security_groups_to_allow. | list | `<list>` | no |
| it_business_unit | IT management: classify the BU related to these components. | string | - | yes |
| it_root_functional_area | IT management: classify the area related to these components. | string | `infra` | no |
| security_groups_to_allow | The list of security group allowed to call the load balancer. Complementary with ips_to_allow. | list | `<list>` | no |
| sns_alerting_arn | The arn of the SNS topic for alerting. If empty, no alarms are defined. | string | - | yes |
| ssl_certificate_arn | If it is a valid ARN, HTTPS listener (tcp 443) is enabled. | string | `` | no |
| ssl_security_policy | The SSL policy applied on the HTTPS listener of the ALB. | string | `ELBSecurityPolicy-2016-08` | no |
| subnet_ids | The list of subnet ids to instanciate application load balancer. | list | - | yes |
| vpc_id | The VPC id where micro-service must be deployed. | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| alb_arn_arn |  |
| alb_arn_suffix |  |
| alb_name |  |
| arn |  |
| arn_suffix |  |
| default_target_group_arn |  |
| default_target_group_arn_suffix |  |
| default_target_group_name |  |
| dns_alb_zone_id |  |
| dns_alias |  |
| dns_name |  |
| http_listener_arn |  |
| https_listener_arn |  |
| security_group |  |

