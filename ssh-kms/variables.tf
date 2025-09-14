variable "region" {
  type = string
}

variable "kms_key_id" {
  type    = string
  default = ""
}

variable "create_kms_key" {
  type = bool
}

variable "kms_key_alias" {
  type = string
}

variable "ssm_prefix" {
  type = string
}

variable "usernames" {
  type = list(string)
}

variable "create_ec2_key_pairs" {
  type = bool
}

variable "ec2_key_name_prefix" {
  type = string
}

variable "algorithm" {
  type = string
}

variable "rsa_bits" {
  type = number
}

variable "public_as_secure" {
  type = bool
}

variable "ssm_tier" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "ec2_keypair" {
  description = "Actors to register as EC2 key pairs. Must be a subset of ['admin'] + usernames."
  type        = list(string)
  default     = ["admin"]  # only admin by default
}
