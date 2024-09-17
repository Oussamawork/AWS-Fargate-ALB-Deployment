module "service_a" {
  source                       = "../../terraform/modules/ecs_service"
  cluster_name                 = module.cluster.cluster_name
  name                         = local.service_a_name
  vpc_id                       = module.network.vpc_id
  container_port               = 80
  protocol                     = "HTTP"
  container_name               = "${local.service_a_name}-container"
  listener_arn                 = module.network.load_balancer_listener_https_arn
  path_pattern                 = ["/${local.service_a_name}/*"]
  referenced_security_group_id = module.network.security_group_id
  subnets                      = module.network.private_subnet_ids
  container_definitions = [
    {
      name      = "${local.service_a_name}-container"
      image     = "${module.ecr_repo_backend_a.ecr_repo_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${local.service_a_name}"
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "ecs"
          "awslogs-create-group"  = "true"
        }
      }
    }
  ]
}

module "service_b" {
  source                       = "../../terraform/modules/ecs_service"
  cluster_name                 = module.cluster.cluster_name
  name                         = local.service_b_name
  vpc_id                       = module.network.vpc_id
  container_name               = "${local.service_b_name}-container"
  container_port               = 80
  protocol                     = "HTTP"
  listener_arn                 = module.network.load_balancer_listener_https_arn
  path_pattern                 = ["/${local.service_b_name}/*"]
  referenced_security_group_id = module.network.security_group_id
  subnets                      = module.network.private_subnet_ids
  container_definitions = [
    {
      name      = "${local.service_b_name}-container"
      image     = "${module.ecr_repo_backend_b.ecr_repo_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${local.service_b_name}"
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "ecs"
          "awslogs-create-group"  = "true"
        }
      }
    }
  ]
}