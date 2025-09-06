locals {
  sgs = {
    for key, sg in var.security_groups :
    key => {
      name        = "${var.name_prefix}${coalesce(sg.name, key)}"
      description = coalesce(sg.description, "Managed by Terraform")
      vpc_id      = var.vpc_id
      tags        = merge(var.tags, { Name = "${var.name_prefix}${coalesce(sg.name, key)}" }) 
    }
  }

  rules = flatten([
    for sg_key, sg in var.security_groups : [
      for idx, r in sg.rules : merge(r, {
        sg_key            = sg_key
        rule_key          = "${sg_key}-${idx}"
        type              = r.type
        protocol          = r.protocol
        from_port         = r.from_port
        to_port           = r.to_port
        cidr_blocks       = coalesce(r.cidr_blocks, [])
        ipv6_cidr_blocks  = coalesce(r.ipv6_cidr_blocks, [])
        source_sgs        = coalesce(r.source_sg_keys, [])
        description       = coalesce(r.description, "")
      })
    ]
  ])
}

resource "aws_security_group" "this" {
  for_each    = local.sgs
  name        = each.value.name
  description = each.value.description
  vpc_id      = each.value.vpc_id
  tags        = each.value.tags
}

locals {
  sg_id_by_key = { for k, sg in aws_security_group.this : k => sg.id }
}

############################
# Rules: IPv4 CIDR
############################
resource "aws_security_group_rule" "cidr_v4" {
  for_each = {
    for r in local.rules :
    "${r.rule_key}-v4" => r
    if length(r.cidr_blocks) > 0
  }

  type              = each.value.type
  protocol          = each.value.protocol
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  cidr_blocks       = each.value.cidr_blocks
  security_group_id = local.sg_id_by_key[each.value.sg_key]
  description       = each.value.description
}

resource "aws_security_group_rule" "cidr_v6" {
  for_each = {
    for r in local.rules :
    "${r.rule_key}-v6" => r
    if length(r.ipv6_cidr_blocks) > 0
  }

  type                = each.value.type
  protocol            = each.value.protocol
  from_port           = each.value.from_port
  to_port             = each.value.to_port
  ipv6_cidr_blocks    = each.value.ipv6_cidr_blocks
  security_group_id   = local.sg_id_by_key[each.value.sg_key]
  description         = each.value.description
}

locals {
  sg_to_sg_flat = flatten([
    for base in local.rules : [
      for src in base.source_sgs : merge(base, {
        source_key = src
        pair_key   = "${base.rule_key}-${src}"
      })
    ]
  ])

  sg_to_sg_map = {
    for r in local.sg_to_sg_flat :
    r.pair_key => r
    if length(r.source_sgs) > 0
  }
}

resource "aws_security_group_rule" "sg_to_sg" {
  for_each = local.sg_to_sg_map

  type                     = each.value.type
  protocol                 = each.value.protocol
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  source_security_group_id = local.sg_id_by_key[each.value.source_key]
  security_group_id        = local.sg_id_by_key[each.value.sg_key]
  description              = each.value.description
}
