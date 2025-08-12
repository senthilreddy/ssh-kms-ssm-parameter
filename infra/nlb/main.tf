# ---- Network Load Balancer ----
resource "aws_lb" "this" {
  name                             = var.name
  load_balancer_type               = "network"
  subnets                          = var.subnet_ids
  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing
  idle_timeout                     = null  # NLB ignores this, but aws provider requires null not 0
  internal                         = var.internal

  tags = merge(var.tags, { Name = var.name })
}

# ---- Target Groups (map) ----
resource "aws_lb_target_group" "tg" {
  for_each = var.target_groups

  name        = "${var.name}-${each.key}"
  port        = each.value.port
  protocol    = each.value.protocol              # "TCP" | "UDP" | "TCP_UDP" | "TLS"
  vpc_id      = var.vpc_id
  target_type = lookup(each.value, "target_type", "instance")

  # Health checks (NLB supports TCP/HTTP/HTTPS/TLS; use TCP for UDP workloads)
  health_check {
    protocol = each.value.health_check_protocol  # e.g., "TCP"
    port     = each.value.health_check_port      # e.g., "traffic-port" or "22" or "1194"
  }

  tags = merge(var.tags, { Name = "${var.name}-${each.key}" })
}

# ---- Listeners (list) ----
resource "aws_lb_listener" "listener" {
  for_each = var.listeners

  load_balancer_arn = aws_lb.this.arn
  port              = each.value.port
  protocol          = each.value.protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg[each.value.target_group_key].arn
  }
}

