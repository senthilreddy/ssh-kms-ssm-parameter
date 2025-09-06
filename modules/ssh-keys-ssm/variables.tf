variable "ssm_prefix" {
  description = "Base SSM prefix (keys will be stored under /<prefix>/admin/{private,public})"
  type        = string
}

variable "create_kms_key" {
  description = "Whether to create a dedicated KMS CMK and alias for SSM encryption"
  type        = bool
  default     = true
}

variable "kms_key_alias" {
  description = "Alias to attach to the created CMK (only used when create_kms_key=true)"
  type        = string
  default     = "alias/ssm-ssh"
}

variable "kms_key_id" {
  description = "Existing KMS key ID or ARN to use when create_kms_key=false"
  type        = string
  default     = ""
}

variable "algorithm" {
  description = "SSH key algorithm (ED25519 or RSA)"
  type        = string
  default     = "ED25519"
  validation {
    condition     = contains(["ED25519", "RSA"], var.algorithm)
    error_message = "algorithm must be ED25519 or RSA"
  }
}

variable "rsa_bits" {
  description = "RSA bit size (used only when algorithm == RSA)"
  type        = number
  default     = 4096
}

variable "public_as_secure" {
  description = "Store the public key as SecureString (encrypted) instead of String"
  type        = bool
  default     = true
}

variable "ssm_tier" {
  description = "SSM Parameter tier (Standard, Advanced, Intelligent-Tiering)"
  type        = string
  default     = "Standard"
}

variable "create_ec2_key_pair" {
  description = "Whether to create an EC2 key pair named <ec2_key_name_prefix>admin"
  type        = bool
  default     = true
}

variable "ec2_key_name_prefix" {
  description = "Prefix for the EC2 key pair name"
  type        = string
  default     = "admin-"
}

variable "tags" {
  description = "Common tags to apply"
  type        = map(string)
  default     = {}
}
