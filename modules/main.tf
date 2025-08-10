module "ssh_keys" {
  source = "./ssh-keys-ssm"

  usernames             = var.usernames
  ssm_prefix            = var.ssm_prefix

  # KMS controls
  create_kms_key        = var.create_kms_key
  kms_key_alias         = var.kms_key_alias
  kms_key_id            = var.kms_key_id
  ec2_keypair  = var.ec2_keypair

  # SSM & encryption options
  public_as_secure      = var.public_as_secure
  ssm_tier              = var.ssm_tier

  # Optional EC2 KeyPair registration
  create_ec2_key_pairs  = var.create_ec2_key_pairs
  ec2_key_name_prefix   = var.ec2_key_name_prefix

  # Key generation
  algorithm             = var.algorithm
  rsa_bits              = var.rsa_bits

  tags                  = var.tags
}