data "aws_iam_policy_document" "admin_invo_stg_policy" {
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
      values   = ["stg"]
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
}

module "invo_stg" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 5.20"

  name        = "Admin_Invo_stg"
  description = "IAM policy to get access to staging resources"
  path        = "/"

  policy = data.aws_iam_policy_document.admin_invo_stg_policy.json
}
