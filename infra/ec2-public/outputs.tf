output "launch_template_id" {
  value = aws_launch_template.this.id
}

output "launch_template_latest_version" {
  value = aws_launch_template.this.latest_version
}

output "autoscaling_group_name" {
  value = aws_autoscaling_group.this.name
}

output "autoscaling_group_arn" {
  value = aws_autoscaling_group.this.arn
}
