variable "region" { 
  type = string 
  }
# VPC inputs
variable "vpc_name" { 
  type = string 
  }
variable "vpc_cidr" { 
  type = string 
  }
variable "azs" { 
  type = list(string) 
  }
variable "public_subnets"{ 
  type = list(string) 
  }
variable "private_subnets"  { 
  type = list(string) 
}
variable "enable_nat_gateway" {
  type    = bool
  default = true
}
variable "single_nat_gateway" {
  type    = bool
  default = true
}

variable "tags" {
  type    = map(string)
  default = {}
}

###################################
# Security Groups inputs
###################################

variable "security_groups" {
  type = map(object({
    name        = optional(string)
    description = optional(string)
    rules = list(object({
      type              = string
      protocol          = string
      from_port         = number
      to_port           = number
      description       = optional(string)
      cidr_blocks       = optional(list(string))
      ipv6_cidr_blocks  = optional(list(string))
      source_sg_keys    = optional(list(string))
    }))
  }))
}

variable "name_prefix" {
  type        = string
  default     = ""
  description = "Optional prefix added to all SG names"
}


###################################
# Public NLB inputs
###################################

# NLB inputs for PRIMARY
variable "nlb_public_name" {
  type = string
}
variable "nlb_public_cross_zone" {
  type    = bool
  default = true
}
variable "nlb_public_target_groups" {
  type = map(object({
    name        = string
    port        = number
    protocol    = string               # "TCP" | "UDP" | "TLS" | "TCP_UDP"
    target_type = optional(string, "instance")
    health_check = optional(object({
      protocol            = string     # e.g., "TCP" or "HTTP"
      port                = string     # e.g., "traffic-port" or "22"
      path                = optional(string)
      healthy_threshold   = optional(number, 3)
      unhealthy_threshold = optional(number, 3)
      interval            = optional(number, 30)
      timeout             = optional(number, 5)
    }), null)
  }))
}
variable "nlb_public_listeners" {
  type = list(object({
    port             = number
    protocol         = string
    target_group_key = string          # must match a key in nlb_public_target_groups
  }))
}

###################################
# Public NLB inputs SECONDARY
###################################

variable "nlb_public_secondary_name" {
  type = string
}
variable "nlb_public_secondary_cross_zone" {
  type    = bool
  default = true
}
variable "nlb_public_secondary_target_groups" {
  type = map(object({
    name        = string
    port        = number
    protocol    = string
    target_type = optional(string, "instance")
    health_check = optional(object({
      protocol            = string
      port                = string
      path                = optional(string)
      healthy_threshold   = optional(number, 3)
      unhealthy_threshold = optional(number, 3)
      interval            = optional(number, 30)
      timeout             = optional(number, 5)
    }), null)
  }))
}
variable "nlb_public_secondary_listeners" {
  type = list(object({
    port             = number
    protocol         = string
    target_group_key = string
  }))
}


################################################
# Private NLB inputs
################################################

variable "nlb_private_name" {
  type = string
}

variable "nlb_private_cross_zone" {
  type    = bool
  default = true
}

variable "nlb_private_target_groups" {
  type = map(object({
    name                  = optional(string)
    port                  = number
    protocol              = string
    target_type           = optional(string, "instance")
    health_check_protocol = optional(string)
    health_check_port     = optional(string)

    # nested health_check object also supported
    health_check = optional(object({
      protocol            = string
      port                = string
      path                = optional(string)
      healthy_threshold   = optional(number, 3)
      unhealthy_threshold = optional(number, 3)
      interval            = optional(number, 30)
      timeout             = optional(number, 5)
    }), null)
  }))
}

variable "nlb_private_listeners" {
  type = list(object({
    port             = number
    protocol         = string
    target_group_key = string
  }))
}



# ###################################

# # SG inputs
# variable "sg_name_vpn" {
#   type    = string
#   default = "vpn-ssh-sg"
# }
# variable "sg_name_private" {
#   type    = string
#   default = "private-instance-sg"
# }
# variable "vpn_udp_port" {
#   type    = number
#   default = 1194
# }
# variable "vpn_tcp_port" {
#   type    = number
#   default = 0
# }
# variable "vpn_ingress_cidrs" {
#   type    = list(string)
#   default = ["0.0.0.0/0"]
# }
# variable "ssh_ingress_cidrs" {
#   type    = list(string)
#   default = ["0.0.0.0/0"]
# }

# # Admin EC2 key name (already created/imported)
# variable "key_name_admin" { type = string }

# # OpenVPN ASG

# variable "openvpn_ami" {
#   type        = string
#   description = "AMI ID for OpenVPN instances"
# }

# variable "openvpn_tg_arns" {
#   type    = list(string)
#   default = []
# }

# variable "private_vm_ami" {
#   type        = string
#   description = "AMI ID for Private VM instances"
# }

# variable "private_vm_tg_arns" {
#   type    = list(string)
#   default = []
# }

# variable "openvpn_name"            { type = string }
# variable "openvpn_instance_type"   { type = string }
# variable "openvpn_min"             { type = number }
# variable "openvpn_max"             { type = number }
# variable "openvpn_desired"         { type = number }
# variable "openvpn_user_data"       { type = string }

# # Private VM ASG
# variable "private_vm_name"          { type = string }
# variable "private_vm_instance_type" { type = string }
# variable "private_vm_min"           { type = number }
# variable "private_vm_max"           { type = number }
# variable "private_vm_desired"       { type = number }
# variable "private_vm_user_data"     { type = string }

# # --- Public NLB vars ---
# variable "nlb_public_name" {
#   type    = string
#   default = "public-nlb"
# }
# variable "nlb_public_cross_zone" {
#   type    = bool
#   default = true
# }
# variable "nlb_public_target_groups" {
#   description = "Map of TGs for public NLB"
#   type = map(object({
#     port                  = number
#     protocol              = string
#     health_check_protocol = string
#     health_check_port     = string
#     target_type           = optional(string)
#   }))
# }

# # --- Private NLB vars ---
# variable "nlb_private_name" {
#   type    = string
#   default = "private-nlb"
# }
# variable "nlb_private_cross_zone" {
#   type    = bool
#   default = true
# }
# variable "nlb_private_target_groups" {
#   description = "Map of TGs for private (internal) NLB"
#   type = map(object({
#     port                  = number
#     protocol              = string
#     health_check_protocol = string
#     health_check_port     = string
#     target_type           = optional(string)
#   }))
# }

# variable "nlb_public_listeners" {
#   description = "Listeners for public NLB (keyed map)"
#   type = map(object({
#     port             = number
#     protocol         = string
#     target_group_key = string
#   }))
# }

# variable "nlb_private_listeners" {
#   description = "Listeners for private NLB (keyed map)"
#   type = map(object({
#     port             = number
#     protocol         = string
#     target_group_key = string
#   }))
# }


# # --- Which TG keys each ASG should attach to ---
# variable "openvpn_tg_key" {
#   description = "Public NLB TG key for OpenVPN (1194)"
#   type        = string
# }
# variable "openvpn_ssh_tg_key" {
#   description = "Public NLB TG key for SSH (22)"
#   type        = string
# }
# variable "private_vm_tg_key" {
#   description = "Private NLB TG key for SSH (22)"
#   type        = string
# }

# # SECOND public NLB (secondary) config – usually same as primary
# variable "nlb_public_secondary_name" {
#   type    = string
#   default = "openvpn-public-nlb-secondary"
# }
# variable "nlb_public_secondary_cross_zone" {
#   type    = bool
#   default = true
# }
# variable "nlb_public_secondary_target_groups" {
#   description = "Map of TGs for the secondary public NLB"
#   type = map(object({
#     port                  = number
#     protocol              = string
#     health_check_protocol = string
#     health_check_port     = string
#     target_type           = optional(string)
#   }))
# }
# variable "nlb_public_secondary_listeners" {
#   description = "Listeners for the secondary public NLB"
#   type = map(object({
#     port             = number
#     protocol         = string
#     target_group_key = string
#   }))
# }

# variable "route53_zone_id" {
#   description = "Hosted zone ID for the public domain"
#   type        = string
# }

# variable "route53_record_name" {
#   description = "Record name for OpenVPN (e.g., vpn.example.com)"
#   type        = string
# }


