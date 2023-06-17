module "ecs_cluster" {
  source  = "terraform-aws-modules/ecs/aws//modules/cluster"
  version = "~> 5.2"

  cluster_name = var.cluster_name

  default_capacity_provider_use_fargate = false
  autoscaling_capacity_providers = {
    # Spot instances
    (local.ecs_capacity_provider) = {
      auto_scaling_group_arn         = module.autoscaling["asg-spot"].autoscaling_group_arn
      managed_termination_protection = "ENABLED"

      managed_scaling = {
        maximum_scaling_step_size = 15
        minimum_scaling_step_size = 5
        status                    = "ENABLED"
        target_capacity           = 100
      }

      default_capacity_provider_strategy = {
        weight = 100
      }
    }
  }

  tags = var.tags
}
