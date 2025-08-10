region               = "ap-south-1"

# Let Terraform create CMK+alias (prevents alias-not-found)
create_kms_key       = true
kms_key_alias        = "alias/ssm-sshs"
kms_key_id           = ""   # ignored when create_kms_key=true

ssm_prefix           = "/client-b/infra/ssh"
usernames            = ["senthilr", "raja"]
ec2_keypair   = ["admin"]

create_ec2_key_pairs = true
ec2_key_name_prefix  = "clientA-"

algorithm            = "ED25519"
rsa_bits             = 4096
public_as_secure     = true
ssm_tier             = "Standard"

tags = {
  Project     = "client-b"
  Environment = "dev"
  Owner       = "platform"
}
