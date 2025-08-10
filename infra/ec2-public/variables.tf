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
  type = string
}

variable "security_group_ids" {
  type = list(string)
}

variable "subnet_ids" {
  type = list(string)
}

variable "user_data" {
  type    = string
  default = ""
}

variable "user_data_base64" {
  type    = string
  default = ""
}

variable "min_size" {
  type    = number
  default = 1
}

variable "max_size" {
  type    = number
  default = 2
}

variable "desired_capacity" {
  type    = number
  default = 1
}

variable "health_check_type" {
  type    = string
  default = "EC2" # or "ELB"
}

variable "health_check_grace_sec" {
  type    = number
  default = 120
}

variable "termination_policies" {
  type    = list(string)
  default = ["OldestInstance"]
}

variable "force_delete" {
  type    = bool
  default = true
}

variable "target_group_arns" {
  type    = list(string)
  default = []
}

variable "tags" {
  type    = map(string)
  default = {}
}
