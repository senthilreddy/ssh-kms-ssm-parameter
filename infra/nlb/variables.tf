variable "name"       { type = string }
variable "vpc_id"     { type = string }
variable "subnet_ids" { type = list(string) }

variable "enable_cross_zone_load_balancing" {
  type    = bool
  default = true
}

variable "internal" {
  type    = bool
  default = false
}

variable "tags" {
  type    = map(string)
  default = {}
}

# Accept EITHER:
# - flat fields: health_check_protocol, health_check_port
# - nested object: health_check = { protocol, port, ... }
variable "target_groups" {
  type = map(object({
    name        = optional(string)
    port        = number
    protocol    = string                      # "TCP" | "UDP" | "TCP_UDP" | "TLS"
    target_type = optional(string, "instance")

    # Nested style (optional)
    health_check = optional(object({
      protocol            = string
      port                = string            # "traffic-port" | "22" | "1194"
      path                = optional(string)
      healthy_threshold   = optional(number, 3)
      unhealthy_threshold = optional(number, 3)
      interval            = optional(number, 30)
      timeout             = optional(number, 5)
    }), null)

    # Flat style (optional)
    health_check_protocol = optional(string)
    health_check_port     = optional(string)
  }))
}

variable "listeners" {
  type = list(object({
    port             = number
    protocol         = string
    target_group_key = string
  }))
}

