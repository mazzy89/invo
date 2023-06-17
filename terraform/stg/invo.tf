module "invo" {
  source = "../modules/invo"

  cluster_name = "invo-${var.env}"
  env          = var.env

  vpc_id = module.vpc.vpc_id

  public_subnets  = module.vpc.public_subnets
  private_subnets = module.vpc.private_subnets

  database_subnet_group = module.vpc.database_subnet_group
}
