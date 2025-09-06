output "vpc_id" { 
    value = module.vpc.vpc_id 
    }
output "public_subnet_ids" { 
    value = module.vpc.public_subnet_ids 
    }
output "private_subnet_ids" { 
    value = module.vpc.private_subnet_ids 
    }
output "sg_ids" {
  value = module.securitygroup.security_group_ids
}

output "vpn_sg_id" {
  value       = try(module.securitygroup.security_group_ids["vpn"], null)
  description = "ID of the VPN SG from the security group module"
}