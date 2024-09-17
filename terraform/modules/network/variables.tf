variable "vpc_name" {
  type = string
}

variable "cidr_block" {
  type = string
}

variable "lb_type" {
  type    = string
  default = "application"
}

variable "domain_name" {
  type = string
}