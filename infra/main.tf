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


############### 
# Vm-Asg
###############

# OpenVPN ASG (private subnets + VPN SG from modules)
module "openvpn_asg" {
  source = "./ec2-public"

  name               = var.openvpn_name
  ami_id             = var.openvpn_ami 
  instance_type      = var.openvpn_instance_type
  key_name           = var.key_name_admin

  # <<< Pull from modules >>>
  security_group_ids = [module.security_groups.vpn_ssh_sg_id]
  subnet_ids         = module.vpc.private_subnet_ids

  user_data          = var.openvpn_user_data

  min_size           = var.openvpn_min
  max_size           = var.openvpn_max
  desired_capacity   = var.openvpn_desired

  health_check_type       = "EC2"
  health_check_grace_sec  = 180
  # Attach to BOTH NLBs' TGs: 1194 and 22 on PRIMARY + SECONDARY
  target_group_arns = [
    module.nlb_public.target_group_arns[var.openvpn_tg_key],
    module.nlb_public.target_group_arns[var.openvpn_ssh_tg_key],
    module.nlb_public_secondary.target_group_arns[var.openvpn_tg_key],
    module.nlb_public_secondary.target_group_arns[var.openvpn_ssh_tg_key]
  ]
  tags = var.tags
}

# Private VM ASG (private subnets + SG that allows SSH from VPN SG)
module "private_vm_asg" {
  source = "./ec2-private"

  name               = var.private_vm_name
  ami_id             = var.private_vm_ami
  instance_type      = var.private_vm_instance_type
  key_name           = var.key_name_admin

  # <<< Pull from modules >>>
  security_group_ids = [module.security_groups.private_instance_sg]
  subnet_ids         = module.vpc.private_subnet_ids

  user_data          = var.private_vm_user_data

  min_size           = var.private_vm_min
  max_size           = var.private_vm_max
  desired_capacity   = var.private_vm_desired
  # Attach to SSH TG on the PRIVATE (internal) NLB
  target_group_arns       = [module.nlb_private.target_group_arns[var.private_vm_tg_key]]
  health_check_type       = "EC2"
  health_check_grace_sec  = 120
  tags = var.tags
}


# --- Public NLB (PRIMARY) stays as you already have: module "nlb_public" ---
module "nlb_public" {
  source = "./nlb"

  name       = var.nlb_public_name
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnet_ids

  enable_cross_zone_load_balancing = var.nlb_public_cross_zone
  internal                         = false

  target_groups = var.nlb_public_target_groups
  listeners     = var.nlb_public_listeners

  tags = var.tags
}

# --- Public NLB (SECONDARY) ---
module "nlb_public_secondary" {
  source = "./nlb"

  name       = var.nlb_public_secondary_name
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnet_ids

  enable_cross_zone_load_balancing = var.nlb_public_secondary_cross_zone
  internal                         = false

  target_groups = var.nlb_public_secondary_target_groups
  listeners     = var.nlb_public_secondary_listeners

  tags = var.tags
}

# --- Private (internal) NLB (Private VMs) ---
module "nlb_private" {
  source = "./nlb"

  name       = var.nlb_private_name
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids   # internal LB sits in private subnets

  enable_cross_zone_load_balancing = var.nlb_private_cross_zone
  internal                         = true

  target_groups = var.nlb_private_target_groups
  listeners     = var.nlb_private_listeners

  tags = var.tags
}

module "route53_failover_public_vpn" {
  source = "./route53-failover"

  zone_id     = var.route53_zone_id
  record_name = var.route53_record_name
  record_type = "A"

  primary_alias_dns_name = module.nlb_public.nlb_dns_name
  primary_alias_zone_id  = module.nlb_public.nlb_zone_id

  secondary_alias_dns_name = module.nlb_public_secondary.nlb_dns_name
  secondary_alias_zone_id  = module.nlb_public_secondary.nlb_zone_id

  evaluate_target_health = true
}