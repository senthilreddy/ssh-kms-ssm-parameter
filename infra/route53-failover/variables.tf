variable "zone_id" {
  description = "Hosted Zone ID for the public zone"
  type        = string
}

variable "record_name" {
  description = "Fully-qualified record name (e.g., vpn.example.com)"
  type        = string
}

variable "record_type" {
  description = "Record type. Use A or AAAA for ALIAS to NLB"
  type        = string
  default     = "A"
}

variable "primary_identifier" {
  description = "SetIdentifier for the PRIMARY record"
  type        = string
  default     = "primary"
}

variable "secondary_identifier" {
  description = "SetIdentifier for the SECONDARY record"
  type        = string
  default     = "secondary"
}

variable "primary_alias_dns_name" {
  description = "DNS name of the PRIMARY target (e.g., NLB DNS)"
  type        = string
}

variable "primary_alias_zone_id" {
  description = "Hosted zone ID of the PRIMARY target (from aws_lb.zone_id)"
  type        = string
}

variable "secondary_alias_dns_name" {
  description = "DNS name of the SECONDARY target"
  type        = string
}

variable "secondary_alias_zone_id" {
  description = "Hosted zone ID of the SECONDARY target"
  type        = string
}

variable "evaluate_target_health" {
  description = "Whether Route53 evaluates target health of the alias"
  type        = bool
  default     = true
}
