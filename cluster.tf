resource "aws_ecs_cluster" "meetup" {
  name = "tf-meetup"
}

resource "aws_iam_policy" "ecs_container_service_policy" {
  name        = "${aws_ecs_cluster.meetup.name}-container-service"
  description = "IAM policy for ECS Container services."

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:Describe*",
        "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
        "elasticloadbalancing:Describe*",
        "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
        "elasticloadbalancing:DeregisterTargets",
        "elasticloadbalancing:RegisterTargets"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "ecs_container_service_role" {
  name = "${aws_ecs_cluster.meetup.name}-container-service"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_container_service_role_policy_attach" {
  role       = "${aws_iam_role.ecs_container_service_role.name}"
  policy_arn = "${aws_iam_policy.ecs_container_service_policy.arn}"
}