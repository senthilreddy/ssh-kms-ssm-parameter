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



