[
  {
    "name": "${container_name}",
    "image": "nginxdemos/hello:${docker_tag}",
    "cpu": ${docker_cpu},
    "memory": ${docker_memory},
    "essential": true,
    "portMappings": [
      {
        "containerPort": ${container_port},
        "protocol": "tcp"
      }
    ],
    "environment": [
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "${aws_region}",
        "awslogs-group": "${cloudwatch_group_name}",
        "awslogs-stream-prefix": "${container_name}"
      }
    }
  }
]