# -------- Launch Template --------
resource "aws_launch_template" "this" {
  name_prefix              = "${var.name}-lt-"
  image_id                 = var.ami_id
  instance_type            = var.instance_type
  key_name                 = try(var.key_name, null)
  vpc_security_group_ids   = var.security_group_ids
  update_default_version   = true
  ebs_optimized            = try(var.ebs_optimized, null)
  disable_api_termination  = try(var.disable_api_termination, null)

  # User data: pass base64 if provided, else encode plaintext
  user_data = var.user_data_base64 != "" ? var.user_data_base64 : (
    var.user_data != "" ? base64encode(var.user_data) : null
  )

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"     # IMDSv2 only
    http_put_response_hop_limit = 2
  }

  monitoring {
    enabled = try(var.detailed_monitoring, true)
  }

  dynamic "block_device_mappings" {
    for_each = var.block_device_mappings
    content {
      device_name = block_device_mappings.value.device_name
      ebs {
        volume_size           = block_device_mappings.value.volume_size
        volume_type           = try(block_device_mappings.value.volume_type, "gp3")
        encrypted             = try(block_device_mappings.value.encrypted, true)
        delete_on_termination = try(block_device_mappings.value.delete_on_termination, true)
        iops                  = try(block_device_mappings.value.iops, null)
        throughput            = try(block_device_mappings.value.throughput, null)
      }
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags          = merge(var.tags, { Name = var.name })
  }

  tag_specifications {
    resource_type = "volume"
    tags          = var.tags
  }

  lifecycle {
    create_before_destroy = true
  }
}

# -------- Auto Scaling Group --------
resource "aws_autoscaling_group" "this" {
  name                      = "${var.name}-asg"
  max_size                  = var.max_size
  min_size                  = var.min_size
  desired_capacity          = var.desired_capacity
  vpc_zone_identifier       = var.subnet_ids
  health_check_type         = try(var.health_check_type, "ELB")   # prefer TG health
  health_check_grace_period = var.health_check_grace_sec
  force_delete              = try(var.force_delete, false)
  termination_policies      = try(var.termination_policies, null)

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  # Attach to NLB/ALB Target Groups (optional)
  target_group_arns = try(var.target_group_arns, [])

  # Propagate tags to instances
  dynamic "tag" {
    for_each = merge(var.tags, { Name = var.name })
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  # Rolling replace on LT changes (AMI, user_data, SGs, etc.)
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 90
      auto_rollback          = true
    }
    triggers = ["launch_template"]
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      desired_capacity,  # avoid spurious diffs during scale events
    ]
  }
}
