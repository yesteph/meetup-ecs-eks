data "aws_ecs_cluster" "ecs_cluster" {
  cluster_name = "${var.ecs_cluster_name}"
}
