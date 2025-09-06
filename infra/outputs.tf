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

# output "vpn_ssh_security_group" { value = module.security_groups.vpn_ssh_sg_id }
# output "private_instance_sg"    { value = module.security_groups.private_instance_sg }
# output "openvpn_asg_name"       { value = module.openvpn_asg.asg_name }
# output "private_vm_asg_name"    { value = module.private_vm_asg.asg_name }
# output "nlb_public_dns_name"  { value = module.nlb_public.nlb_dns_name }
# output "nlb_private_dns_name" { value = module.nlb_private.nlb_dns_name }
