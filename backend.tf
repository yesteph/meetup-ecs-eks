terraform {
  backend "s3" {
    bucket = "mybucket-perso1"
    key    = "meetup-ecs-eks/terraform.tfstate"
    region = "eu-west-1"
  }
}