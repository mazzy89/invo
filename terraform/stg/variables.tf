variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "vpc_cidr" {
  type    = string
  default = "192.168.0.0/20"
}

variable "env" {
  type    = string
  default = "stg"
}
