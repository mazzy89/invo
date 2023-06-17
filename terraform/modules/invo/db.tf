module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 5.9"

  identifier = var.cluster_name

  engine            = "mysql"
  engine_version    = "5.7"
  instance_class    = var.db_instance_type
  allocated_storage = 30

  db_name  = "phalcon_invo"
  username = "phalcon"
  port     = "3306"

  create_random_password = true

  iam_database_authentication_enabled = false

  vpc_security_group_ids = [module.db_security_group.security_group_id]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  # Enhanced Monitoring - see example for details on how to create the role
  # by yourself, in case you don't want to create it automatically
  create_monitoring_role = false
  tags                   = var.tags

  # DB subnet group
  db_subnet_group_name = var.database_subnet_group
  skip_final_snapshot  = true

  blue_green_update = {
    enabled = true
  }

  # DB parameter group
  family = "mysql5.7"

  # DB option group
  major_engine_version = "5.7"

  # Database Deletion Protection
  deletion_protection = true

  parameters = [
    {
      name  = "character_set_client"
      value = "utf8mb4"
    },
    {
      name  = "character_set_server"
      value = "utf8mb4"
    }
  ]

  options = [
    {
      option_name = "MARIADB_AUDIT_PLUGIN"

      option_settings = [
        {
          name  = "SERVER_AUDIT_EVENTS"
          value = "CONNECT"
        },
        {
          name  = "SERVER_AUDIT_FILE_ROTATIONS"
          value = "37"
        },
      ]
    },
  ]
}

module "db_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "${var.cluster_name}-db"
  description = "DB MySQL security group"
  vpc_id      = var.vpc_id

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "mysql-tcp"
      source_security_group_id = module.service_security_group.security_group_id
    }
  ]

  number_of_computed_ingress_with_source_security_group_id = 1

  egress_rules = ["all-all"]

  tags = var.tags
}

resource "aws_secretsmanager_secret" "db_master_password" {
  name = "/${var.cluster_name}/invo/db_master_password"
}

resource "aws_secretsmanager_secret_version" "db_master_password" {
  secret_id     = aws_secretsmanager_secret.db_master_password.id
  secret_string = module.db.db_instance_password
}
