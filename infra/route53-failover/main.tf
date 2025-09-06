# PRIMARY failover alias record
resource "aws_route53_record" "primary" {
  zone_id = var.zone_id
  name    = var.record_name
  type    = var.record_type

  set_identifier = var.primary_identifier
  failover_routing_policy { type = "PRIMARY" }

  alias {
    name                   = var.primary_alias_dns_name
    zone_id                = var.primary_alias_zone_id
    evaluate_target_health = var.evaluate_target_health
  }

  allow_overwrite = var.allow_overwrite
}

# SECONDARY failover alias record
resource "aws_route53_record" "secondary" {
  zone_id = var.zone_id
  name    = var.record_name
  type    = var.record_type

  set_identifier = var.secondary_identifier
  failover_routing_policy { type = "SECONDARY" }

  alias {
    name                   = var.secondary_alias_dns_name
    zone_id                = var.secondary_alias_zone_id
    evaluate_target_health = var.evaluate_target_health
  }

  allow_overwrite = var.allow_overwrite
}
