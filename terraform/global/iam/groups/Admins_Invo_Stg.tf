module "admins_invo_stg" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-group-with-policies"
  version = "~> 5.20"

  name = "Admins_Invo_Stg"

  group_users = [
    "tomas@hostaway.com",
  ]

  attach_iam_self_management_policy = true
  enable_mfa_enforcment             = false


  custom_group_policy_arns = [
    data.terraform_remote_state.policies.outputs.admin_invo_stg_policy_arn,
  ]
}
