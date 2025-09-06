
# Client A - TFVARS
################################################
# SSM + KMS + ADMIN EC2 Key Pairs 
################################################
region               = "ap-south-1"

# Let Terraform create CMK+alias (prevents alias-not-found)
create_kms_key       = true
kms_key_alias        = "alias/ssm-ssh"
kms_key_id           = ""   # ignored when create_kms_key=true

ssm_prefix           = "/client-a/infra/ssh"
usernames            = ["admin"]
ec2_keypair   = ["admin"]

create_ec2_key_pairs = true
ec2_key_name_prefix  = "client-a"

algorithm            = "ED25519"
rsa_bits             = 4096
public_as_secure     = true
ssm_tier             = "Standard"

#### Tags

tags = {
  Project     = "client-a"
  Environment = "dev"
}


# ##############################             
# # VPC-Modules 
# ##############################
vpc_name     = "client-a-vpc"
vpc_cidr     = "10.0.0.0/16"
azs          = ["ap-south-1a", "ap-south-1b"]
public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets = ["10.0.11.0/24", "10.0.12.0/24"]

enable_nat_gateway = true
single_nat_gateway = true


# ##############################             
# # Security Group-Modules 
# ##############################

# sg_name_vpn     = "openvpn-ssh-sg"
# sg_name_private = "private-instance-sg"

# vpn_udp_port      = 1194
# vpn_tcp_port      = 0                   # set to 1194 if you also need TCP
# vpn_ingress_cidrs = ["0.0.0.0/0"]       # lock down to office IPs in prod
# ssh_ingress_cidrs = ["0.0.0.0/0"]       # lock down to your IPs

# ##############################             
# # Ec2 Private and Public
# ##############################
# # Shared admin key pair name
# key_name_admin = "client-admin"
# # OpenVPN group
# openvpn_name            = "openvpn"
# openvpn_instance_type   = "t3.micro"
# openvpn_min             = 1
# openvpn_max             = 2
# openvpn_desired         = 1
# openvpn_ami             = "ami-0d0ad8bb301edb745"
# openvpn_user_data = <<-EOT
# #!/bin/bash
# set -e
# yum update -y
# yum install -y nc openvpn iptables iproute
# echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
# sysctl -p
# # your full OpenVPN provisioning here...
# EOT
# openvpn_tg_arns = []  # add NLB TG ARNs if you have them

# # Private VM group
# private_vm_name            = "private-vm"
# private_vm_instance_type   = "t3.micro"
# private_vm_min             = 1
# private_vm_max             = 2
# private_vm_desired         = 1
# private_vm_ami             = "ami-0d0ad8bb301edb745"
# private_vm_user_data = <<-EOT
# #!/bin/bash
# yum update -y
# yum install -y nc
# EOT
# private_vm_tg_arns = []


# # -----------------------
# # PUBLIC NLB (PRIMARY)
# # -----------------------
# nlb_public_name       = "openvpn-nlb-primary"
# nlb_public_cross_zone = true

# nlb_public_target_groups = {
#   openvpn = {
#     port                  = 1194
#     protocol              = "TCP_UDP"  # one TG handles both TCP+UDP
#     health_check_protocol = "TCP"
#     health_check_port     = "1194"
#     target_type           = "instance"
#   }
#   ssh = {
#     port                  = 22
#     protocol              = "TCP"
#     health_check_protocol = "TCP"
#     health_check_port     = "22"
#     target_type           = "instance"
#   }
# }

# # Must be a MAP (keyed) — not a list
# nlb_public_listeners = {
#   vpn_1194 = { port = 1194, protocol = "TCP_UDP", target_group_key = "openvpn" }
#   ssh_22   = { port = 22,   protocol = "TCP",     target_group_key = "ssh" }
# }

# # -----------------------
# # PUBLIC NLB (SECONDARY / FAILOVER)
# # -----------------------
# nlb_public_secondary_name       = "openvpn-nlb-secondary"
# nlb_public_secondary_cross_zone = true

# # Same shape as primary; no module references/ARNs in tfvars
# nlb_public_secondary_target_groups = {
#   openvpn = {
#     port                  = 1194
#     protocol              = "TCP_UDP"
#     health_check_protocol = "TCP"
#     health_check_port     = "1194"
#     target_type           = "instance"
#   }
#   ssh = {
#     port                  = 22
#     protocol              = "TCP"
#     health_check_protocol = "TCP"
#     health_check_port     = "22"
#     target_type           = "instance"
#   }
# }

# nlb_public_secondary_listeners = {
#   vpn_1194 = { port = 1194, protocol = "TCP_UDP", target_group_key = "openvpn" }
#   ssh_22   = { port = 22,   protocol = "TCP",     target_group_key = "ssh" }
# }




# # --- Private (internal) NLB (SSH only) ---
# nlb_private_name        = "private-ssh-nlb"
# nlb_private_cross_zone  = true

# nlb_private_target_groups = {
#   ssh = {
#     port                  = 22
#     protocol              = "TCP"
#     health_check_protocol = "TCP"
#     health_check_port     = "22"
#     target_type           = "instance"
#   }
# }

# nlb_private_listeners = {
#   ssh_22 = { port = 22, protocol = "TCP", target_group_key = "ssh" }
# }

# # --- ASG → TG key mappings ---
# openvpn_tg_key     = "openvpn"   # from nlb_public_target_groups
# openvpn_ssh_tg_key = "ssh"       # from nlb_public_target_groups
# private_vm_tg_key  = "ssh"       # from nlb_private_target_groups

# ##############################             
# # Route53 failover
# ##############################

# route53_zone_id     = ""     # your hosted zone ID
# route53_record_name = "senthilreddy.com"    # your desired name
