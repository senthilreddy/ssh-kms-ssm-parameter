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

module "securitygroup" {
  source          = "./security-groups"
  name_prefix     = var.name_prefix
  vpc_id          = module.vpc.vpc_id
  tags            = var.tags
  security_groups = var.security_groups
}

################################################
# --- Public NLB (PRIMARY) 
################################################

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

################################################
# --- Public NLB (SECONDARY) for redundancy
################################################

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

################################################
# --- Private NLB (internal)
################################################

module "nlb_private" {
  source = "./nlb"

  name       = var.nlb_private_name
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids
  enable_cross_zone_load_balancing = var.nlb_private_cross_zone
  internal   = true

  target_groups = var.nlb_private_target_groups
  listeners     = var.nlb_private_listeners

  tags = var.tags
}


##############################
#OpenVPN ASG (private subnets)
##############################

module "openvpn_asg" {
  source = "./ec2-public"

  name           = var.openvpn_name
  ami_id         = var.openvpn_ami
  instance_type  = var.openvpn_instance_type
  key_name       = var.key_name_admin

  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [module.securitygroup.security_group_ids["vpn"]]

  user_data = var.openvpn_user_data

  min_size         = var.openvpn_min
  max_size         = var.openvpn_max
  desired_capacity = var.openvpn_desired

  health_check_grace_sec = 180

  target_group_arns = [
    module.nlb_public.target_group_arns[var.openvpn_tg_key],
    module.nlb_public.target_group_arns[var.openvpn_ssh_tg_key],
    module.nlb_public_secondary.target_group_arns[var.openvpn_tg_key],
    module.nlb_public_secondary.target_group_arns[var.openvpn_ssh_tg_key],
  ]

  tags = var.tags
  instance_tags   = var.openvpn_instance_tags
}

#####################################
#Private VM ASG (private subnets)
#####################################

module "private_vm_asg" {
  source = "./ec2-private"

  name          = var.private_vm_name
  ami_id        = var.private_vm_ami
  instance_type = var.private_vm_instance_type
  key_name      = var.key_name_admin

  security_group_ids = [module.securitygroup.security_group_ids["private"]]
  subnet_ids         = module.vpc.private_subnet_ids

  user_data = var.private_vm_user_data

  min_size         = var.private_vm_min
  max_size         = var.private_vm_max
  desired_capacity = var.private_vm_desired

  target_group_arns = [
    module.nlb_private.target_group_arns[var.private_vm_tg_key]
  ]

  health_check_grace_sec = 120
  tags = var.tags
  instance_tags   = var.private_vm_instance_tags
}

##############################             
# Route53 failover Inputs
##############################

module "route53_failover_public_vpn" {
  source = "./route53-failover"

  zone_id     = var.route53_zone_id
  record_name = var.route53_record_name
  record_type = "A"

  primary_alias_dns_name   = module.nlb_public.dns_name
  primary_alias_zone_id    = module.nlb_public.zone_id
  secondary_alias_dns_name = module.nlb_public_secondary.dns_name
  secondary_alias_zone_id  = module.nlb_public_secondary.zone_id

  evaluate_target_health = true
}
