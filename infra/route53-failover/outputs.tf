output "primary_record_fqdn" {
  value = aws_route53_record.primary.fqdn
}

output "secondary_record_fqdn" {
  value = aws_route53_record.secondary.fqdn
}
