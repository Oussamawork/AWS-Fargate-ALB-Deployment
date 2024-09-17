data "aws_route53_zone" "this" {
  name = var.domain_name
}

data "aws_availability_zones" "available" {}