output "arn" {
  value       = aws_lb.this.arn
  description = "ARN of the NLB"
}

output "dns_name" {
  value       = aws_lb.this.dns_name
  description = "DNS name of the NLB"
}

output "zone_id" {
  value       = aws_lb.this.zone_id
  description = "Hosted zone ID of the NLB"
}

# Map: target group key -> TG ARN (matches aws_lb_target_group.tg in main.tf)
output "target_group_arns" {
  value       = { for k, tg in aws_lb_target_group.tg : k => tg.arn }
  description = "Map of target group keys to ARNs"
}
