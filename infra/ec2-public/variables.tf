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

variable "iam_instance_profile_name" {
  type    = string
  default = null
}

variable "security_group_ids" {
  type = list(string)
}

variable "subnet_ids" {
  type = list(string)
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "user_data" {
  type    = string
  default = ""
}

variable "user_data_base64" {
  type    = string
  default = ""
}

variable "ebs_optimized" {
  type    = bool
  default = null
}

variable "disable_api_termination" {
  type    = bool
  default = null
}

variable "detailed_monitoring" {
  type    = bool
  default = true
}

variable "block_device_mappings" {
  type = list(object({
    device_name           = string
    volume_size           = number
    volume_type           = optional(string, "gp3")
    encrypted             = optional(bool, true)
    delete_on_termination = optional(bool, true)
    iops                  = optional(number)
    throughput            = optional(number)
  }))
  default = []
}

variable "max_size" {
  type = number
}

variable "min_size" {
  type = number
}

variable "desired_capacity" {
  type = number
}

variable "health_check_grace_sec" {
  type    = number
  default = 300
}

variable "force_delete" {
  type    = bool
  default = false
}

variable "termination_policies" {
  type    = list(string)
  default = []
}

variable "target_group_arns" {
  type    = list(string)
  default = []
}

variable "enable_capacity_rebalance" {
  type    = bool
  default = false
}

variable "instance_tags" {
  description = "Extra tags for instances (merged with global tags)"
  type        = map(string)
  default     = {}
}

variable "volume_tags" {
  description = "Extra tags for volumes (merged with global tags)"
  type        = map(string)
  default     = {}
}