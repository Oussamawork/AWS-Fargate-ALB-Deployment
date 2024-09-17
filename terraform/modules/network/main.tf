# vpc
resource "aws_vpc" "this" {
  cidr_block = var.cidr_block
  tags = {
    Name = var.vpc_name
  }
}

# internet gateway
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
}

# two public subnets
resource "aws_subnet" "public_1" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(var.cidr_block, 8, 1)
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "${var.vpc_name}-public-1"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(var.cidr_block, 8, 2)
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "${var.vpc_name}-public-2"
  }
}

# two private subnets
resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(var.cidr_block, 8, 3)
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "${var.vpc_name}-private-1"
  }
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(var.cidr_block, 8, 4)
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "${var.vpc_name}-private-2"
  }
}

# route table   
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

# route table association
resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

# route table association
resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private.id
}

# route table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
}

resource "aws_route" "private" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this.id
}

# nat gateway
resource "aws_nat_gateway" "this" {
  subnet_id     = aws_subnet.public_1.id
  allocation_id = aws_eip.this.id
}

# elastic ip
resource "aws_eip" "this" {
  domain = "vpc"
}

# public load balancer 
resource "aws_lb" "this" {
  name               = "${var.vpc_name}-lb"
  internal           = false
  load_balancer_type = var.lb_type
  subnets            = [aws_subnet.public_1.id, aws_subnet.public_2.id]
  security_groups    = [aws_security_group.this.id]
}

# public load balancer listener
resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# listener https with fixed response
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.this.arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found, Try Again with /backend-a or /backend-b"
      status_code  = "404"
    }
  }
}


# security group
resource "aws_security_group" "this" {
  name        = "${var.vpc_name}-lb-security-group"
  description = "Security group for ${var.vpc_name} load balancer"
  vpc_id      = aws_vpc.this.id
}

# security group rule
resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.this.id
  from_port         = 80
  to_port           = 80
  ip_protocol       = "TCP"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "https" {
  security_group_id = aws_security_group.this.id
  from_port         = 443
  to_port           = 443
  ip_protocol       = "TCP"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "egress" {
  security_group_id = aws_security_group.this.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_acm_certificate" "this" {
  domain_name       = var.domain_name
  validation_method = "DNS"
}

# acm validation
resource "aws_route53_record" "validation" {
  for_each = {
    for dvo in aws_acm_certificate.this.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  allow_overwrite = true
  zone_id         = data.aws_route53_zone.this.zone_id
  name            = each.value.name
  type            = each.value.type
  ttl             = 60
  records         = [each.value.record]
}

resource "aws_acm_certificate_validation" "this" {
  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [aws_route53_record.validation[var.domain_name].fqdn]
}

resource "aws_route53_record" "this" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_lb.this.dns_name
    zone_id                = aws_lb.this.zone_id
    evaluate_target_health = true
  }
}