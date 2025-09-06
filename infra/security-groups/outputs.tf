output "security_group_ids" {
  description = "Map of SG keys to IDs"
  value       = { for k, v in aws_security_group.this : k => v.id }
}
