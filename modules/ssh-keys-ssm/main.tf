terraform {
  required_version = ">= 1.5.0"
  required_providers {
    tls = { source = "hashicorp/tls", version = "~> 4.0" }
    aws = { source = "hashicorp/aws", version = ">= 5.0" }
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_partition" "current" {}

# (Optional) Create a dedicated CMK + alias if requested
resource "aws_kms_key" "ssm_ssh" {
  count               = var.create_kms_key ? 1 : 0
  description         = "CMK for encrypting SSH keys in SSM"
  enable_key_rotation = true
  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Sid       = "EnableRootPermissions",
        Effect    = "Allow",
        Principal = {
          AWS = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action   = "kms:*",
        Resource = "*"
      }
    ]
  })
  tags = var.tags
}

resource "aws_kms_alias" "ssm_ssh" {
  count         = var.create_kms_key ? 1 : 0
  name          = var.kms_key_alias
  target_key_id = aws_kms_key.ssm_ssh[0].key_id
}

locals {
  path_prefix           = "/${trim(var.ssm_prefix, "/")}"
  all_actors            = toset(concat(["admin"], var.usernames))
  kms_key_id_effective  = var.create_kms_key ? aws_kms_alias.ssm_ssh[0].name : var.kms_key_id

  # NEW: only create keypairs for requested actors that exist in all_actors
  ec2_actors = toset([
    for a in var.ec2_keypair : a
    if contains(tolist(local.all_actors), a)
  ])
}

# ========= Generate SSH keys =========
resource "tls_private_key" "keys" {
  for_each = local.all_actors

  algorithm = var.algorithm
  rsa_bits  = var.algorithm == "RSA" ? var.rsa_bits : null
}

# ========= Store in SSM (SecureString) =========
resource "aws_ssm_parameter" "priv" {
  for_each = local.all_actors

  name        = "${local.path_prefix}/${each.key}/private"
  description = "Private SSH key for ${each.key}"
  type        = "SecureString"
  key_id      = local.kms_key_id_effective
  value       = tls_private_key.keys[each.key].private_key_openssh
  overwrite   = true
  tier        = var.ssm_tier

  tags = merge(var.tags, { "name" = each.key, "scope" = "ssh-private" })

  lifecycle {
    precondition {
      condition     = var.create_kms_key || (try(length(var.kms_key_id), 0) > 0)
      error_message = "Set kms_key_id when create_kms_key=false."
    }
  }
}

resource "aws_ssm_parameter" "pub" {
  for_each = local.all_actors

  name        = "${local.path_prefix}/${each.key}/public"
  description = "Public SSH key for ${each.key}"
  type        = var.public_as_secure ? "SecureString" : "String"
  key_id      = var.public_as_secure ? local.kms_key_id_effective : null
  value       = tls_private_key.keys[each.key].public_key_openssh
  overwrite   = true
  tier        = var.ssm_tier

  tags = merge(var.tags, { "name" = each.key, "scope" = "ssh-public" })
}

# ========= (Optional) Register EC2 Key Pairs =========
resource "aws_key_pair" "ec2" {
  for_each = var.create_ec2_key_pairs ? local.ec2_actors : toset([])

  key_name   = "${var.ec2_key_name_prefix}${each.key}"
  public_key = tls_private_key.keys[each.key].public_key_openssh

  tags = merge(var.tags, {
    "Name"  = "${var.ec2_key_name_prefix}${each.key}"
    "owner" = each.key
  })
}
