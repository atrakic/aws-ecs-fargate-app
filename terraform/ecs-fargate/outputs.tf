# outputs.tf

output "alb_hostname" {
  value = aws_alb.this.dns_name
}
