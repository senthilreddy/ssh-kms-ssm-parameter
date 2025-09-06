variable "vpc_id" {
  type        = string
  description = "VPC ID where SGs will be created"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Common tags merged into every SG"
}

variable "name_prefix" {
  type        = string
  default     = ""
  description = "Optional prefix added to all SG names"
}

variable "security_groups" {
  description = "Map of security groups and rules"
  type = map(object({
    name        = optional(string)
    description = optional(string)
    rules = list(object({
      type              = string            # ingress | egress
      protocol          = string            # tcp | udp | icmp | -1
      from_port         = number
      to_port           = number
      description       = optional(string)
      cidr_blocks       = optional(list(string))
      ipv6_cidr_blocks  = optional(list(string))
      source_sg_keys    = optional(list(string)) # references keys in this same map
    }))
  }))

  validation {
    condition     = alltrue([for _, sg in var.security_groups : length(sg.rules) > 0])
    error_message = "Each security group must define at least one rule."
  }
}


