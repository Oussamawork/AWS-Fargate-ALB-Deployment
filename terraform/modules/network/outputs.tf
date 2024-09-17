
output "vpc_id" {
  value = aws_vpc.this.id
}

output "load_balancer_arn" {
  value = aws_lb.this.arn
}

output "load_balancer_dns" {
  value = aws_lb.this.dns_name
}

output "load_balancer_listener_arn" {
  value = aws_lb_listener.this.arn
}

output "security_group_id" {
  value = aws_security_group.this.id
}

output "load_balancer_listener_https_arn" {
  value = aws_lb_listener.https.arn
}

output "private_subnet_ids" {
  value = [aws_subnet.private_1.id, aws_subnet.private_2.id]
}

output "public_subnet_ids" {
  value = [aws_subnet.public_1.id, aws_subnet.public_2.id]
}