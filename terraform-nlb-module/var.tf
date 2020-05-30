variable "env-name" {
  default ="test"
}

variable "region" {
  default ="eu-west-3"
}

variable "nlb" {
  default = ["LB1", "LB2"]
}

variable "vpc_region" {
  default =""
}

variable "vpc_id" {
  default = ""
}
