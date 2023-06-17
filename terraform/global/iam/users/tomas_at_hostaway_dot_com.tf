module "tomas_at_hostaway_dot_com" {
  source = "terraform-aws-modules/iam/aws//modules/iam-user"
  version = "~> 5.20"

  name          = "tomas@hostaway.com"
  force_destroy = true

  password_reset_required = false
}