variable "name" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "key_name" {
  type    = string
  default = null
}

variable "security_group_ids" {
  type = list(string)
}

variable "subnet_ids" {
  type = list(string)
}

# User data: provide either plaintext or base64 (module will encode plaintext)
variable "user_data" {
  type    = string
  default = ""
}

variable "user_data_base64" {
  type    = string
  default = ""
}

# Scaling
variable "min_size" {
  type = number
}

variable "max_size" {
  type = number
}

variable "desired_capacity" {
  type = number
}

# Health / LB
variable "health_check_type" {
  type    = string
  default = "ELB" # "ELB" or "EC2"
}

variable "health_check_grace_sec" {
  type    = number
  default = 180
}

variable "force_delete" {
  type    = bool
  default = false
}

variable "termination_policies" {
  type    = list(string)
  default = null
}

variable "target_group_arns" {
  type    = list(string)
  default = []
}

variable "capacity_rebalance" {
  type    = bool
  default = true
}

# Extras
variable "tags" {
  type    = map(string)
  default = {}
}

variable "detailed_monitoring" {
  type    = bool
  default = true
}

variable "ebs_optimized" {
  type    = bool
  default = null
}

variable "disable_api_termination" {
  type    = bool
  default = null
}

variable "block_device_mappings" {
  type = list(object({
    device_name           = string
    volume_size           = number
    volume_type           = optional(string)
    encrypted             = optional(bool)
    delete_on_termination = optional(bool)
    iops                  = optional(number)
    throughput            = optional(number)
  }))
  default = [
    {
      device_name = "/dev/xvda"
      volume_size = 20
      volume_type = "gp3"
      encrypted   = true
    }
  ]
}
