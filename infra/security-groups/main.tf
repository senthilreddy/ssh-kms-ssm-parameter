# --- VPN + SSH SG ---
resource "aws_security_group" "vpn_ssh" {
  name        = var.sg_name_vpn
  description = "Allow OpenVPN and SSH"
  vpc_id      = var.vpc_id

  # OpenVPN UDP
  dynamic "ingress" {
    for_each = var.vpn_udp_port == 0 ? [] : [1]
    content {
      from_port   = var.vpn_udp_port
      to_port     = var.vpn_udp_port
      protocol    = "udp"
      cidr_blocks = var.vpn_ingress_cidrs
      description = "OpenVPN UDP"
    }
  }

  # OpenVPN TCP
  dynamic "ingress" {
    for_each = var.vpn_tcp_port == 0 ? [] : [1]
    content {
      from_port   = var.vpn_tcp_port
      to_port     = var.vpn_tcp_port
      protocol    = "tcp"
      cidr_blocks = var.vpn_ingress_cidrs
      description = "OpenVPN TCP"
    }
  }

  # SSH to VPN hosts
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_ingress_cidrs
    description = "SSH"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All egress"
  }

  tags = merge(var.tags, { Name = var.sg_name_vpn })
}

# --- Private-VM SG (SSH only from VPN SG) ---
resource "aws_security_group" "private_vm" {
  name        = var.sg_name_private
  description = "Allow SSH from VPN SG"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.vpn_ssh.id]
    description     = "SSH from VPN SG"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All egress"
  }

  tags = merge(var.tags, { Name = var.sg_name_private })
}
