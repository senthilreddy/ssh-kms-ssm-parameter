data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_partition" "current" {}

resource "aws_kms_key" "ssm_ssh" {
  count               = var.create_kms_key ? 1 : 0
  description         = "CMK for encrypting SSH keys in SSM"
  enable_key_rotation = true
  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Sid       = "EnableRootPermissions",
      Effect    = "Allow",
      Principal = {
        AWS = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"
      },
      Action   = "kms:*",
      Resource = "*"
    }]
  })
  tags = var.tags
}

resource "aws_kms_alias" "ssm_ssh" {
  count         = var.create_kms_key ? 1 : 0
  name          = var.kms_key_alias
  target_key_id = aws_kms_key.ssm_ssh[0].key_id
}

locals {
  admin_name           = "admin"
  path_prefix          = "/${trim(var.ssm_prefix, "/")}"
  kms_key_id_effective = var.create_kms_key ? aws_kms_alias.ssm_ssh[0].name : var.kms_key_id
}

resource "tls_private_key" "admin" {
  algorithm = var.algorithm
  rsa_bits  = var.algorithm == "RSA" ? var.rsa_bits : null
}

resource "aws_ssm_parameter" "admin_private" {
  name        = "${local.path_prefix}/${local.admin_name}/private"
  description = "Private SSH key for ${local.admin_name}"
  type        = "SecureString"
  key_id      = local.kms_key_id_effective
  value       = tls_private_key.admin.private_key_openssh
  overwrite   = true
  tier        = var.ssm_tier
  tags        = merge(var.tags, { "name" = local.admin_name, "scope" = "ssh-private" })

  lifecycle {
    precondition {
      condition     = var.create_kms_key || (try(length(var.kms_key_id), 0) > 0)
      error_message = "Set kms_key_id when create_kms_key=false."
    }
  }
}

resource "aws_ssm_parameter" "admin_public" {
  name        = "${local.path_prefix}/${local.admin_name}/public"
  description = "Public SSH key for ${local.admin_name}"
  type        = var.public_as_secure ? "SecureString" : "String"
  key_id      = var.public_as_secure ? local.kms_key_id_effective : null
  value       = tls_private_key.admin.public_key_openssh
  overwrite   = true
  tier        = var.ssm_tier
  tags        = merge(var.tags, { "name" = local.admin_name, "scope" = "ssh-public" })
}

resource "aws_key_pair" "admin" {
  count      = var.create_ec2_key_pair ? 1 : 0
  key_name   = "${var.ec2_key_name_prefix}${local.admin_name}"
  public_key = tls_private_key.admin.public_key_openssh
  tags       = merge(var.tags, { "Name" = "${var.ec2_key_name_prefix}${local.admin_name}", "owner" = local.admin_name })
}
