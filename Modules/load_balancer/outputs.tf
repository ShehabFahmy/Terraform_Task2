output "id" {
  value = aws_lb.app_lb.id
}

output "dns-name" {
  value = aws_lb.app_lb.dns_name
  description = "The DNS name of the Load Balancer"
}
