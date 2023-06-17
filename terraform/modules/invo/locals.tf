locals {
  ecs_capacity_provider = "spot-ecs-cp-${var.env}"

  container_name = "invo"
  container_port = 80
}
