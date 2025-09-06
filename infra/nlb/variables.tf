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

variable "target_groups" {
  type = map(object({
    name        = optional(string)
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

