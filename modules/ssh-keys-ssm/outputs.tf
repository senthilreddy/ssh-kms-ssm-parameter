output "admin_public_key_openssh" {
  description = "Admin public key (OpenSSH format)"
  value       = tls_private_key.admin.public_key_openssh
}

output "ssm_parameter_admin_private" {
  description = "SSM name for the admin private key"
  value       = aws_ssm_parameter.admin_private.name
}

output "ssm_parameter_admin_public" {
  description = "SSM name for the admin public key"
  value       = aws_ssm_parameter.admin_public.name
}

output "ec2_key_pair_name" {
  description = "EC2 key pair name (empty if not created)"
  value       = var.create_ec2_key_pair ? aws_key_pair.admin[0].key_name : ""
}
output "ssm_parameter_names_admin_ssh_key" {
  description = "Admin SSM parameter names"
  value = {
    admin_private = aws_ssm_parameter.admin_private.name
    admin_public  = aws_ssm_parameter.admin_public.name
  }
  sensitive = true
}
