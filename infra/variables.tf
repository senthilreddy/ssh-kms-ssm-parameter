###################################
# Common Inputs
###################################

variable "public_as_secure" {
  type    = bool
  default = false
}

variable "ssm_prefix" {
  type = string
}

variable "ssm_tier" {
  type = string
}

variable "rsa_bits" {
  type = string
}

variable "kms_key_alias" {
  type = string
}

variable "algorithm" {
  type = string
}

variable "ec2_keypair" {
  description = "Actors to register as EC2 key pairs. Must be a subset of ['admin'] + usernames."
  type        = list(string)
  default     = ["admin"]
}

variable "region" { 
  type = string 
}

variable "kms_key_id" {
  type    = string
  default = ""
}

variable "create_ec2_key_pairs" {
  type = bool
  default = false
}

variable "ec2_key_name_prefix" {
  type = string
}

variable "create_kms_key" {
  type = bool
  default = false
}

variable "usernames" {
  type = list(string)
}

###################################
# VPC inputs
###################################

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
variable "nlb_public_listeners" {
  type = list(object({
    port             = number
    protocol         = string
    target_group_key = string
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

#####################################
# OpenVPN ASG Inputs (private subnets)
#####################################

variable "openvpn_name" {
  type = string
}

variable "openvpn_ami" {
  type = string
}

variable "openvpn_instance_type" {
  type = string
}

variable "key_name_admin" {
  type = string
}

variable "openvpn_min" {
  type = number
}

variable "openvpn_max" {
  type = number
}

variable "openvpn_desired" {
  type = number
}

variable "openvpn_tg_key" {
  type = string
}

variable "openvpn_ssh_tg_key" {
  type = string
}

variable "openvpn_user_data" {
  type = string
}

variable "vpn_allowed_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "ssh_admin_cidrs" {
  type    = list(string)
  default = []
}

# ASG knobs
variable "health_check_grace_sec" {
  type    = number
  default = 180
}

variable "enable_capacity_rebalance" {
  type    = bool
  default = false
}




##############################             
# Private VM ASG Inputs
##############################

# --- Private VM ASG inputs ---
variable "private_vm_name"           { type = string }
variable "private_vm_ami"            { type = string }
variable "private_vm_instance_type"  { type = string }
variable "private_vm_user_data"      { type = string }

variable "private_vm_min"            { type = number }
variable "private_vm_max"            { type = number }
variable "private_vm_desired"        { type = number }
variable "private_vm_tg_key"         { type = string }

##############################             
# Route53 failover Inputs
##############################

variable "route53_zone_id" {
  type = string
}

variable "route53_record_name" {
  type = string 
}

