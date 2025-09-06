# ---- Network Load Balancer ----
resource "aws_lb" "this" {
  name                             = var.name
  load_balancer_type               = "network"
  subnets                          = var.subnet_ids
  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing
  internal                         = var.internal
  tags = merge(var.tags, { Name = var.name })
}

# ---- Target Groups (map) ----
resource "aws_lb_target_group" "tg" {
  for_each = var.target_groups

  # Keep TG name <= 32 chars total
  name        = try(each.value.name, "${var.name}-${each.key}")
  port        = each.value.port
  protocol    = each.value.protocol
  vpc_id      = var.vpc_id
  target_type = try(each.value.target_type, "instance")

  # Normalize health-check: prefer nested, then flat; default sensible TCP
  health_check {
    protocol            = try(each.value.health_check.protocol, each.value.health_check_protocol, "TCP")
    port                = try(each.value.health_check.port,     each.value.health_check_port,     "traffic-port")
    path                = try(each.value.health_check.path, null)
    healthy_threshold   = try(each.value.health_check.healthy_threshold,   3)
    unhealthy_threshold = try(each.value.health_check.unhealthy_threshold, 3)
    interval            = try(each.value.health_check.interval,            30)
    timeout             = try(each.value.health_check.timeout,             5)
  }

  tags = merge(var.tags, { Name = try(each.value.name, "${var.name}-${each.key}") })
}

# ---- Listeners (list -> map for for_each) ----
resource "aws_lb_listener" "listener" {
  for_each = { for l in var.listeners : "${l.protocol}-${l.port}" => l }

  load_balancer_arn = aws_lb.this.arn
  port              = each.value.port
  protocol          = each.value.protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg[each.value.target_group_key].arn
  }
}



