/*
Initially, the security group rules for ECS container instances can be managed outside the security_group itself to allow external update.
 Example : Add an application load balancer to acces the cluster.

 BUT, we reached the max number of rules per security group with the increase of LB per a single ECS cluster.
 So, we reviewed the strategy to provision external_ecs_access_sg which must be added on the source element which access the cluster.
*/

resource "aws_security_group" "ecs_access_sg" {
  name        = "${local.component_id}"
  description = "Allow traffic to container instances of the ECS cluster."
  vpc_id      = "${var.vpc_id}"

  tags {
    Name = "${local.component_id}"
  }
}

resource "aws_security_group_rule" "allow_egress_from_ecs" {
  security_group_id = "${aws_security_group.ecs_access_sg.id}"

  type = "egress"

  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group" "external_ecs_access_sg" {
  name        = "${local.component_id}-access"
  description = "Empty security group, to be added on element which need access to the ECS cluster."
  vpc_id      = "${var.vpc_id}"

  tags {
    Name = "${local.component_id}-access"
  }
}

resource "aws_security_group_rule" "allow_external_access_to_ecs" {
  security_group_id = "${aws_security_group.ecs_access_sg.id}"

  type = "ingress"

  from_port                = 32768
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.external_ecs_access_sg.id}"
  to_port                  = 65535
}

# Allow NFS to EFS server
resource "aws_security_group_rule" "ecs_to_efs" {
  from_port                = 2049
  protocol                 = "tcp"
  to_port                  = 2049
  type                     = "ingress"
  source_security_group_id = "${aws_security_group.ecs_access_sg.id}"
  security_group_id        = "${var.efs_security_group_id}"

  count = "${var.efs_security_group_id != "" ? 1:0}"
}
