variable "zone_id" {
  type = string
}

variable "record_name" {
  type = string
}

variable "record_type" {
  type = string
}

variable "primary_alias_dns_name" {
  type = string
}

variable "primary_alias_zone_id" {
  type = string
}

variable "secondary_alias_dns_name" {
  type = string
}

variable "secondary_alias_zone_id" {
  type = string
}

variable "evaluate_target_health" {
  type    = bool
  default = true
}

variable "primary_identifier" {
  type    = string
  default = "primary"
}

variable "secondary_identifier" {
  type    = string
  default = "secondary"
}

variable "allow_overwrite" {
  type    = bool
  default = true
}
