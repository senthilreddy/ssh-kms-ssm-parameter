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

tags = {
  Project     = "client-a"
  Environment = "dev"
  Owner       = "platform"
}

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

