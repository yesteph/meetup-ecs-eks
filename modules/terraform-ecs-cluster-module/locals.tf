locals {
  checked_ec2_scaling_policy = "${lookup(var.__ec2_scaling_policy_format, var.ec2_scaling_policy)}"

  cluster_name              = "tf-${var.env}-${var.it_business_unit}-${var.cluster_name}"
  component_id              = "tf-${var.env}-${var.it_business_unit}-ecs-${var.cluster_name}"
  user_data_md5             = "${md5(file("${path.module}/templates/user-data.tpl"))}"
  ecs_cluster_arn           = "arn:aws:ecs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:cluster/${local.cluster_name}"
}
