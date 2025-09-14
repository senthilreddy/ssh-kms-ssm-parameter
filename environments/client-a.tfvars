
# Client A - TFVARS
################################################
# SSM + KMS + ADMIN EC2 Key Pairs  Inputs
################################################
region               = "ap-south-1"

create_kms_key       = true
kms_key_alias        = "alias/ssm-ssh"
kms_key_id           = "" 

ssm_prefix           = "/client-a/infra/ssh"
usernames            = ["admin"]
ec2_keypair          = ["admin"]

create_ec2_key_pairs = true
ec2_key_name_prefix  = "client-a"

algorithm            = "ED25519"
rsa_bits             = 4096
public_as_secure     = true
ssm_tier             = "Standard"

################################################
# Tags Inputs
################################################

tags = {
  Project     = "client-a"
  Environment = "dev"
}

# Extra tags only for public-facing (OpenVPN) instances
openvpn_instance_tags = {
  Role       = "openvpn-server"
  Tier       = "bastion"
}

# Extra tags only for private VMs
private_vm_instance_tags = {
  Role       = "app-private"
  Tier       = "backend"
}


# ##############################             
# # VPC-Modules Inputs
# ##############################
vpc_name     = "client-a-vpc"
vpc_cidr     = "10.0.0.0/16"
azs          = ["ap-south-1a", "ap-south-1b"]
public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets = ["10.0.11.0/24", "10.0.12.0/24"]

enable_nat_gateway = true
single_nat_gateway = true


# ##############################             
# Security Group-Modules Inputs
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
# Public NLB (PRIMARY) Inputs
################################################
nlb_public_name       = "openvpn-nlb-primary"
nlb_public_cross_zone = true

nlb_public_target_groups = {
  openvpn = {
    name                  = "client-a-openvpn-primary" 
    port                  = 1194
    protocol              = "TCP_UDP"
    health_check_protocol = "TCP"
    health_check_port     = "1194"
    target_type           = "instance"
  }
  ssh = {
    name                  = "client-a-ssh-primary"
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
# Public NLB (SECONDARY) Inputs
################################################
nlb_public_secondary_name       = "openvpn-nlb-secondary"
nlb_public_secondary_cross_zone = true

# Same shape as primary; no module references/ARNs in tfvars
nlb_public_secondary_target_groups = {
  openvpn = {
    name                  = "client-a-openvpn-secondary"
    port                  = 1194
    protocol              = "TCP_UDP"
    health_check_protocol = "TCP"
    health_check_port     = "1194"
    target_type           = "instance"
  }
  ssh = {
    name                  = "client-a-ssh-secondary"
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
# --- Private NLB (internal) Inputs
################################################

nlb_private_name       = "private-ssh-nlb"
nlb_private_cross_zone = true

nlb_private_target_groups = {
  ssh = {
    name                  = "client-a-private-ssh"
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


##############################             
# OpenVPN ASG Inputs
##############################

openvpn_name            = "openvpn"
openvpn_ami             = "ami-0d0ad8bb301edb745"
openvpn_instance_type   = "t2.medium"
key_name_admin          = "client-a-admin"

openvpn_min             = 1
openvpn_max             = 1
openvpn_desired         = 1

# --- ASG → TG key mappings ---
openvpn_tg_key          = "openvpn"   # from nlb_public target_groups
openvpn_ssh_tg_key      = "ssh"       # from nlb_public target_groups

# Allow the world for demo; tighten in prod
vpn_allowed_cidrs       = ["0.0.0.0/0"]
ssh_admin_cidrs         = []          # prefer SSM; add office /32 if needed

# Optional knobs
health_check_grace_sec  = 300
enable_capacity_rebalance = false #Capacity Rebalancing is only relevant for Spot

# openvpn_user_data = <<-EOT
# #!/bin/bash
# #!/bin/bash
# yum update -y

# %{ if enable_ssm }
# yum install -y amazon-ssm-agent
# systemctl enable amazon-ssm-agent
# systemctl start amazon-ssm-agent
# %{ endif }

# %{ if enable_cloudwatch_logging }
# yum install -y amazon-cloudwatch-agent
# systemctl enable amazon-cloudwatch-agent
# systemctl start amazon-cloudwatch-agent

# cat <<EOF >/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
# {
#   "logs": {
#     "logs_collected": {
#       "files": {
#         "collect_list": [
#           { "file_path": "/var/log/messages", "log_group_name": "${log_group_prefix}-syslog", "log_stream_name": "{instance_id}" },
#           { "file_path": "/var/log/cloud-init.log", "log_group_name": "${log_group_prefix}-cloudinit", "log_stream_name": "{instance_id}" }
#         ]
#       }
#     }
#   }
# }
# EOF

# /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
#   -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s
# %{ endif }
# EOT

# Enable SSM + CloudWatch logging for debugging
enable_ssm                = true
enable_cloudwatch_logging = true
cloudwatch_log_group_names = ["client-a-openvpn-logs"]

##############################             
# Private VM ASG Inputs
##############################

private_vm_name           = "private-vm"
private_vm_ami            = "ami-0d0ad8bb301edb745"
private_vm_instance_type  = "t3.micro"

private_vm_min            = 1
private_vm_max            = 1
private_vm_desired        = 1

private_vm_tg_key         = "ssh"

# private_vm_user_data = <<-EOT
# #!/bin/bash
# yum update -y

# %{ if enable_ssm }
# yum install -y amazon-ssm-agent
# systemctl enable amazon-ssm-agent
# systemctl start amazon-ssm-agent
# %{ endif }

# %{ if enable_cloudwatch_logging }
# yum install -y amazon-cloudwatch-agent
# systemctl enable amazon-cloudwatch-agent
# systemctl start amazon-cloudwatch-agent

# cat <<EOF >/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
# {
#   "logs": {
#     "logs_collected": {
#       "files": {
#         "collect_list": [
#           { "file_path": "/var/log/messages", "log_group_name": "${log_group_prefix}-syslog", "log_stream_name": "{instance_id}" },
#           { "file_path": "/var/log/cloud-init.log", "log_group_name": "${log_group_prefix}-cloudinit", "log_stream_name": "{instance_id}" }
#         ]
#       }
#     }
#   }
# }
# EOF

# /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
#   -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s
# %{ endif }

# EOF

# /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
#   -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s
# %{ endif ~}
# EOT

##############################             
# Route53 failover Inputs
##############################
route53_zone_id     = "Z0259799296D7PA0JE29K"   # Your hosted zone ID
route53_record_name = "vpn.senthilreddy.com"  # Or "senthilreddy.com"

