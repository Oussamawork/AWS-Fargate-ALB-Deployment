module "network" {
  source      = "../../terraform/modules/network"
  vpc_name    = local.stage
  cidr_block  = "10.0.0.0/16"
  domain_name = local.domain_name
}

module "ecr_repo_backend_a" {
  source        = "../../terraform/modules/aws_ecr"
  ecr_repo_name = "backend_a"
}

module "ecr_repo_backend_b" {
  source        = "../../terraform/modules/aws_ecr"
  ecr_repo_name = "backend_b"
}

module "cluster" {
  source = "../../terraform/modules/ecs_cluster"
  name   = local.stage
}