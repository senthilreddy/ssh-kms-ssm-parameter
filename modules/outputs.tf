output "admin_key_ssm_parameter_names" {
  description = "Admin SSM parameter names"
  value = module.ssh_keys.ssm_parameter_names_admin_ssh_key
  sensitive = true
}
