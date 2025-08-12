output "nlb_arn" {
  value = aws_lb.this.arn
}

output "nlb_dns_name" {
  value = aws_lb.this.dns_name
}

output "target_group_arns" {
  description = "Map of target group key => ARN"
  value = { for k, tg in aws_lb_target_group.tg : k => tg.arn }
}

output "listener_arns" {
  value = [for l in aws_lb_listener.listener : l.arn]
}

output "nlb_zone_id" {
  value = aws_lb.this.zone_id
}