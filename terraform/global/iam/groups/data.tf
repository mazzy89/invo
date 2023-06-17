data "terraform_remote_state" "policies" {
  backend = "local"

  config = {
    path = "../policies/terraform.tfstate"
  }
}

data "terraform_remote_state" "users" {
  backend = "local"

  config = {
    path = "../users/terraform.tfstate"
  }
}
