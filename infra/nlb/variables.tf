variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  description = "Subnets for the NLB (usually public subnets)."
  type        = list(string)
}

variable "enable_cross_zone_load_balancing" {
  type    = bool
  default = true
}

variable "internal" {
  description = "Whether the NLB is internal."
  type        = bool
  default     = false
}

# Map of target groups to create.
# Keys are short names used to reference from listeners (e.g., "openvpn", "ssh").
variable "target_groups" {
  type = map(object({
    port                   = number
    protocol               = string           # "TCP" | "UDP" | "TCP_UDP" | "TLS"
    health_check_protocol  = string           # "TCP" | "HTTP" | ...
    health_check_port      = string           # e.g., "traffic-port" or "22"
    target_type            = optional(string) # default "instance"
  }))
}

variable "listeners" {
  description = "Map of listeners keyed by a stable name"
  type = map(object({
    port             = number
    protocol         = string           # TCP | UDP | TCP_UDP | TLS
    target_group_key = string           # must match a key in target_groups
  }))
}


variable "tags" {
  type    = map(string)
  default = {}
}
