
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
ec2_keypair          = ["admin"]

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
name_prefix = "client-a-"
security_groups = {
  vpn = {
    name        = "openvpn-ssh-sg"
    description = "Allow OpenVPN and optional SSH"
    rules = [
      { type="ingress", protocol="udp", from_port=1194, to_port=1194,
        cidr_blocks=["0.0.0.0/0"], description="OpenVPN UDP" },

      { type="ingress", protocol="tcp", from_port=22, to_port=22,
        cidr_blocks=["0.0.0.0/0"], description="SSH to VPN" },

      { type="egress", protocol="-1", from_port=0, to_port=0,
        cidr_blocks=["0.0.0.0/0"], ipv6_cidr_blocks=["::/0"], description="All egress" }
    ]
  }

  private = {
    name        = "private-instance-sg"
    description = "Allow SSH from VPN SG only"
    rules = [
      { type="ingress", protocol="tcp", from_port=22, to_port=22,
        source_sg_keys=["vpn"], description="SSH from VPN SG" },

      { type="egress", protocol="-1", from_port=0, to_port=0,
        cidr_blocks=["0.0.0.0/0"], ipv6_cidr_blocks=["::/0"], description="All egress" }
    ]
  }
}

################################################
# --- Public NLB (PRIMARY) 
################################################
nlb_public_name       = "openvpn-nlb-primary"
nlb_public_cross_zone = true

nlb_public_target_groups = {
  openvpn = {
    name                  = "client-a-openvpn"   # <= 32 chars recommended
    port                  = 1194
    protocol              = "TCP_UDP"
    health_check_protocol = "TCP"
    health_check_port     = "1194"
    target_type           = "instance"
  }
  ssh = {
    name                  = "client-a-ssh"
    port                  = 22
    protocol              = "TCP"
    health_check_protocol = "TCP"
    health_check_port     = "22"
    target_type           = "instance"
  }
}

nlb_public_listeners = [
  { port = 1194, protocol = "TCP_UDP", target_group_key = "openvpn" },
  { port = 22,   protocol = "TCP",     target_group_key = "ssh"     },
]

################################################
# --- Public NLB (SECONDARY) for redundancy ---
################################################
nlb_public_secondary_name       = "openvpn-nlb-secondary"
nlb_public_secondary_cross_zone = true

# Same shape as primary; no module references/ARNs in tfvars
nlb_public_secondary_target_groups = {
  openvpn = {
    name                  = "client-a2-openvpn"
    port                  = 1194
    protocol              = "TCP_UDP"
    health_check_protocol = "TCP"
    health_check_port     = "1194"
    target_type           = "instance"
  }
  ssh = {
    name                  = "client-a2-ssh"
    port                  = 22
    protocol              = "TCP"
    health_check_protocol = "TCP"
    health_check_port     = "22"
    target_type           = "instance"
  }
}

nlb_public_secondary_listeners = [
  { port = 1194, protocol = "TCP_UDP", target_group_key = "openvpn" },
  { port = 22,   protocol = "TCP",     target_group_key = "ssh"     },
]


################################################
# --- Private NLB (internal)
################################################

nlb_private_name       = "private-ssh-nlb"
nlb_private_cross_zone = true

nlb_private_target_groups = {
  ssh = {
    port                  = 22
    protocol              = "TCP"
    health_check_protocol = "TCP"
    health_check_port     = "22"
    target_type           = "instance"
  }
}

# Must be a LIST (not a map)
nlb_private_listeners = [
  { port = 22, protocol = "TCP", target_group_key = "ssh" }
]


# ##############################             
# # OpenVPN ASG
# ##############################

# openvpn_name            = "openvpn"
# openvpn_ami             = "ami-0d0ad8bb301edb745"
# openvpn_instance_type   = "t3.micro"
# key_name_admin = "client-admin"
# openvpn_min             = 1
# openvpn_max             = 1
# openvpn_desired         = 1
# # --- ASG → TG key mappings ---
# openvpn_tg_key     = "openvpn"   # from nlb_public_target_groups
# openvpn_ssh_tg_key = "ssh"       # from nlb_public_target_groups
# private_vm_tg_key  = "ssh"       # from nlb_private_target_groups
# openvpn_user_data = <<-EOT
# #!/bin/bash
# set -e
# yum update -y
# yum install -y nc openvpn iptables iproute
# echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
# sysctl -p
# # your full OpenVPN provisioning here...
# EOT




# ############################## old

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

# # OpenVPN group
# openvpn_name            = "openvpn"




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






# ##############################             
# # Route53 failover
# ##############################

# route53_zone_id     = ""     # your hosted zone ID
# route53_record_name = "senthilreddy.com"    # your desired name
