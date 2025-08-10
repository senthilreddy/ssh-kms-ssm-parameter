region               = "ap-south-1"

# Let Terraform create CMK+alias (prevents alias-not-found)
create_kms_key       = true
kms_key_alias        = "alias/ssm-sshs"
kms_key_id           = ""   # ignored when create_kms_key=true

ssm_prefix           = "/client-a/infra/ssh"
usernames            = ["senthilr", "raja"]
ec2_keypair   = ["admin"]

create_ec2_key_pairs = true
ec2_key_name_prefix  = "client-a"

algorithm            = "ED25519"
rsa_bits             = 4096
public_as_secure     = true
ssm_tier             = "Standard"

##############################             
# Infra-Modules 
##############################
vpc_name     = "client-a-vpc"
vpc_cidr     = "10.0.0.0/16"
azs          = ["ap-south-1a", "ap-south-1b"]
public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets = ["10.0.11.0/24", "10.0.12.0/24"]

enable_nat_gateway = true
single_nat_gateway = true

sg_name_vpn     = "openvpn-ssh-sg"
sg_name_private = "private-instance-sg"

vpn_udp_port      = 1194
vpn_tcp_port      = 0                   # set to 1194 if you also need TCP
vpn_ingress_cidrs = ["0.0.0.0/0"]       # lock down to office IPs in prod
ssh_ingress_cidrs = ["0.0.0.0/0"]       # lock down to your IPs

##############################             
# Ec2 Private and Public
##############################
# Shared admin key pair name
key_name_admin = "client-aadmin"
# OpenVPN group
openvpn_name            = "openvpn"
openvpn_instance_type   = "t3.micro"
openvpn_min             = 1
openvpn_max             = 2
openvpn_desired         = 1
openvpn_ami             = "ami-0d0ad8bb301edb745"
openvpn_user_data = <<-EOT
#!/bin/bash
set -e
yum update -y
yum install -y nc openvpn iptables iproute
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p
# your full OpenVPN provisioning here...
EOT
openvpn_tg_arns = []  # add NLB TG ARNs if you have them

# Private VM group
private_vm_name            = "private-vm"
private_vm_instance_type   = "t3.micro"
private_vm_min             = 1
private_vm_max             = 2
private_vm_desired         = 1
private_vm_ami             = "ami-0d0ad8bb301edb745"
private_vm_user_data = <<-EOT
#!/bin/bash
yum update -y
yum install -y nc
EOT
private_vm_tg_arns = []

tags = {
  Project     = "client-a"
  Environment = "dev"
}
