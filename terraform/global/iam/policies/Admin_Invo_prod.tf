data "aws_iam_policy_document" "admin_invo_prod_policy" {
  statement {
    sid = ""
    actions = [
      "ec2:*",
      "ecs:*",
      "autoscaling:*"
    ]
    resources = ["*"]
    effect    = "Allow"
    condition {
      test     = "StringEquals"
      values   = ["prod"]
      variable = "aws:ResourceTag/environment"
    }
  }

  statement {
    sid = ""
    actions = [
      "ec2:Describe*",
      "ecs:Describe*",
      "ecs:ListClusters",
      "elasticloadbalancing:Describe*"
    ]
    resources = ["*"]
    effect    = "Allow"
  }

  statement {
    sid       = ""
    actions   = ["ec2:CreateTags", "ec2:DeleteTags"]
    resources = ["*"]
    effect    = "Deny"
  }
}

module "invo_prod" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 5.20"

  name        = "Admin_Invo_prod"
  description = "IAM policy to get access to production resources"
  path        = "/"

  policy = data.aws_iam_policy_document.admin_invo_prod_policy.json
}
