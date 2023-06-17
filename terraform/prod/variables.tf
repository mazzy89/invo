variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "vpc_cidr" {
  type    = string
  default = "172.31.0.0/16"
}

variable "env" {
  type    = string
  default = "prod"
}
