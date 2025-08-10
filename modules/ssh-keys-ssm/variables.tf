variable "usernames" {
  description = "Additional user key names (admin is implicit)."
  type        = list(string)
  default     = []
}

variable "ssm_prefix" {
  description = "Base SSM path (with or without leading slash)."
  type        = string
  validation {
    condition     = can(regex("^[A-Za-z0-9_./-]+$", var.ssm_prefix))
    error_message = "ssm_prefix may only contain letters, numbers, / . - _"
  }
}

variable "create_kms_key" {
  description = "Create a dedicated CMK and alias for SSM encryption."
  type        = bool
  default     = false
}

variable "kms_key_alias" {
  description = "Alias to create when create_kms_key=true."
  type        = string
  default     = "alias/ssm-ssh"
}

variable "kms_key_id" {
  description = "Existing KMS key identifier (key-id/ARN/alias). Ignored if create_kms_key=true."
  type        = string
  default     = ""
}

variable "public_as_secure" {
  description = "Store public keys as SecureString (encrypted)."
  type        = bool
  default     = true
}

variable "ssm_tier" {
  description = "SSM parameter tier: Standard, Advanced, or Intelligent-Tiering."
  type        = string
  default     = "Standard"
}

variable "create_ec2_key_pairs" {
  description = "Also create EC2 KeyPair objects from the generated public keys."
  type        = bool
  default     = true
}

variable "ec2_key_name_prefix" {
  description = "Prefix for EC2 key pair names."
  type        = string
  default     = "kp-"
}

variable "algorithm" {
  description = "Key algorithm: ED25519 or RSA."
  type        = string
  default     = "ED25519"
  validation {
    condition     = contains(["ED25519", "RSA"], var.algorithm)
    error_message = "algorithm must be ED25519 or RSA."
  }
}

variable "rsa_bits" {
  description = "RSA key size, used only when algorithm == RSA."
  type        = number
  default     = 4096
}

variable "tags" {
  description = "Common tags to apply."
  type        = map(string)
  default     = {}
}

variable "ec2_keypair" {
  description = "Actors to register as EC2 key pairs. Must be a subset of ['admin'] + usernames."
  type        = list(string)
  default     = ["admin"]  # only admin by default
}

# Who can administer the key (rotate, delete, manage policy)
variable "kms_admin_arns" {
  description = "IAM ARNs that administer the CMK."
  type        = list(string)
  default     = []
}

# Who can use the key to encrypt/decrypt parameters
variable "kms_user_arns" {
  description = "IAM ARNs (roles/users) allowed to Encrypt/Decrypt with the CMK."
  type        = list(string)
  default     = []
}

