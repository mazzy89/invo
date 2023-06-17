data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

resource "local_file" "ecs_task_definition" {
  content = templatefile("${path.module}/data/task_definition.json.tmpl", {
    region = data.aws_region.current.name
    env    = var.env

    execution_role_arn = aws_iam_role.service.arn

    db_host                 = module.db.db_instance_endpoint
    db_username             = module.db.db_instance_username
    db_password_version_arn = aws_secretsmanager_secret_version.db_master_password.arn
  })

  filename = "${path.module}/../../../task_definition.${var.env}.json"
}

module "service_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "${var.cluster_name}-app"
  description = "ECS Service invo security group"
  vpc_id      = var.vpc_id

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
      source_security_group_id = module.alb.security_group_id
    }
  ]

  number_of_computed_ingress_with_source_security_group_id = 1

  egress_rules = ["all-all"]

  tags = {
    immutable_metadata = "{\"purpose\":\"${var.cluster_name}\"}"
  }
}

data "aws_iam_policy_document" "service_assume" {
  statement {
    sid     = "ECSServiceAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }
  }

  statement {
    sid     = "ECSTasksServiceAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "service" {
  name_prefix = "${var.cluster_name}-app-"
  path        = "/"

  assume_role_policy    = data.aws_iam_policy_document.service_assume.json
  force_detach_policies = true

  tags = var.tags
}

data "aws_iam_policy_document" "service" {
  statement {
    sid       = "ECSService"
    resources = ["*"]

    actions = [
      "ec2:Describe*",
      "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
      "elasticloadbalancing:DeregisterTargets",
      "elasticloadbalancing:Describe*",
      "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
      "elasticloadbalancing:RegisterTargets"
    ]
  }

  statement {
    resources = [
      aws_secretsmanager_secret.db_master_password.arn,
      "arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:key/*"
    ]

    actions = [
      "secretsmanager:GetSecretValue",
      "kms:Decrypt"
    ]
  }

  statement {
    resources = [
      "arn:aws:logs:*:*:*"
    ]

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams"
    ]
  }
}

resource "aws_iam_policy" "service" {
  name_prefix = "${var.cluster_name}-app-"
  policy      = data.aws_iam_policy_document.service.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "service" {
  role       = aws_iam_role.service.name
  policy_arn = aws_iam_policy.service.arn
}
