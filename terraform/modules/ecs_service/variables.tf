# variables
variable "name" {
  type = string
}

variable "cpu" {
  type    = number
  default = 256
}

variable "memory" {
  type    = number
  default = 512
}

variable "network_mode" {
  type    = string
  default = "awsvpc"
}

variable "vpc_id" {
  type = string
}

variable "container_name" {
  type = string
}

variable "container_port" {
  type = number
}

variable "protocol" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "container_definitions" {
  type = list(object({
    name      = string
    image     = string
    essential = bool
    portMappings = list(object({
      containerPort = number
      hostPort      = number
    }))
    logConfiguration = object({
      logDriver = string
      options   = map(string)
    })
  }))
}

variable "desired_count" {
  type    = number
  default = 1
}

variable "listener_arn" {
  type = string
}

variable "path_pattern" {
  type = list(string)
}

variable "referenced_security_group_id" {
  type = string
}

variable "subnets" {
  type = list(string)
}
