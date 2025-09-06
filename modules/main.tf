module "ssh_keys" {
  source = "./ssh-keys-ssm"

  # required
  ssm_prefix = "/client-a/infra/ssh"

  # pick ONE of these KMS options
  create_kms_key = true
  kms_key_alias  = "alias/ssm-ssh"     # used only if create_kms_key = true
  # create_kms_key = false
  # kms_key_id     = "arn:aws:kms:ap-south-1:123456789012:key/..."  # existing KMS

  # optional
  public_as_secure    = true
  ssm_tier            = "Standard"
  create_ec2_key_pair = true
  ec2_key_name_prefix = "client-a-"
  tags = {
    project = "client-a"
    owner   = "platform"
  }
}
