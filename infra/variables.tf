variable "region"           { type = string }

# VPC inputs
variable "vpc_name"         { type = string }
variable "vpc_cidr"         { type = string }
variable "azs"              { type = list(string) }
variable "public_subnets"   { type = list(string) }
variable "private_subnets"  { type = list(string) }
variable "enable_nat_gateway" {
  type    = bool
  default = true
}
variable "single_nat_gateway" {
  type    = bool
  default = true
}

# SG inputs
variable "sg_name_vpn" {
  type    = string
  default = "vpn-ssh-sg"
}
variable "sg_name_private" {
  type    = string
  default = "private-instance-sg"
}
variable "vpn_udp_port" {
  type    = number
  default = 1194
}
variable "vpn_tcp_port" {
  type    = number
  default = 0
}
variable "vpn_ingress_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}
variable "ssh_ingress_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

# Admin EC2 key name (already created/imported)
variable "key_name_admin" { type = string }

# OpenVPN ASG

variable "openvpn_ami" {
  type        = string
  description = "AMI ID for OpenVPN instances"
}

variable "openvpn_tg_arns" {
  type    = list(string)
  default = []
}

variable "private_vm_ami" {
  type        = string
  description = "AMI ID for Private VM instances"
}

variable "private_vm_tg_arns" {
  type    = list(string)
  default = []
}

variable "openvpn_name"            { type = string }
variable "openvpn_instance_type"   { type = string }
variable "openvpn_min"             { type = number }
variable "openvpn_max"             { type = number }
variable "openvpn_desired"         { type = number }
variable "openvpn_user_data"       { type = string }

# Private VM ASG
variable "private_vm_name"          { type = string }
variable "private_vm_instance_type" { type = string }
variable "private_vm_min"           { type = number }
variable "private_vm_max"           { type = number }
variable "private_vm_desired"       { type = number }
variable "private_vm_user_data"     { type = string }

variable "tags" {
  type    = map(string)
  default = {}
}

# --- Public NLB vars ---
variable "nlb_public_name" {
  type    = string
  default = "public-nlb"
}
variable "nlb_public_cross_zone" {
  type    = bool
  default = true
}
variable "nlb_public_target_groups" {
  description = "Map of TGs for public NLB"
  type = map(object({
    port                  = number
    protocol              = string
    health_check_protocol = string
    health_check_port     = string
    target_type           = optional(string)
  }))
}

# --- Private NLB vars ---
variable "nlb_private_name" {
  type    = string
  default = "private-nlb"
}
variable "nlb_private_cross_zone" {
  type    = bool
  default = true
}
variable "nlb_private_target_groups" {
  description = "Map of TGs for private (internal) NLB"
  type = map(object({
    port                  = number
    protocol              = string
    health_check_protocol = string
    health_check_port     = string
    target_type           = optional(string)
  }))
}

variable "nlb_public_listeners" {
  description = "Listeners for public NLB (keyed map)"
  type = map(object({
    port             = number
    protocol         = string
    target_group_key = string
  }))
}

variable "nlb_private_listeners" {
  description = "Listeners for private NLB (keyed map)"
  type = map(object({
    port             = number
    protocol         = string
    target_group_key = string
  }))
}


# --- Which TG keys each ASG should attach to ---
variable "openvpn_tg_key" {
  description = "Public NLB TG key for OpenVPN (1194)"
  type        = string
}
variable "openvpn_ssh_tg_key" {
  description = "Public NLB TG key for SSH (22)"
  type        = string
}
variable "private_vm_tg_key" {
  description = "Private NLB TG key for SSH (22)"
  type        = string
}
