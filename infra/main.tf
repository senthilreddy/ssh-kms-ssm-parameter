module "vpc" {
  source            = "./vpc"
  vpc_name         = var.vpc_name
  vpc_cidr         = var.vpc_cidr
  azs              = var.azs
  public_subnets   = var.public_subnets
  private_subnets  = var.private_subnets
  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway
  tags             = var.tags
}

module "security_groups" {
  source           = "./security-groups"
  vpc_id           = module.vpc.vpc_id

  sg_name_vpn      = var.sg_name_vpn
  sg_name_private  = var.sg_name_private

  vpn_udp_port     = var.vpn_udp_port
  vpn_tcp_port     = var.vpn_tcp_port
  vpn_ingress_cidrs = var.vpn_ingress_cidrs
  ssh_ingress_cidrs = var.ssh_ingress_cidrs

  tags             = var.tags
}

output "vpc_id"                 { value = module.vpc.vpc_id }
output "public_subnet_ids"      { value = module.vpc.public_subnet_ids }
output "private_subnet_ids"     { value = module.vpc.private_subnet_ids }
output "vpn_ssh_security_group" { value = module.security_groups.vpn_ssh_sg_id }
output "private_instance_sg"    { value = module.security_groups.private_instance_sg }
