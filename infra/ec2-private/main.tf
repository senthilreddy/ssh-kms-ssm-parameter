resource "aws_launch_template" "this" {
  name_prefix             = "${var.name}-lt-"
  image_id                = var.ami_id
  instance_type           = var.instance_type
  key_name                = var.key_name
  vpc_security_group_ids  = var.security_group_ids
  update_default_version  = true
  user_data = (
    length(var.user_data_base64) > 0 ? var.user_data_base64 :
    length(var.user_data)        > 0 ? base64encode(var.user_data) :
    null
  )

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"   # IMDSv2 only
  }

  tag_specifications {
    resource_type = "instance"
    tags          = merge(var.tags, { Name = var.name })
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      var.tags,
      var.instance_tags,
      { Name = var.name }
    )
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge(
      var.tags,
      var.volume_tags
    )
  }

  lifecycle { create_before_destroy = true }
}

resource "aws_autoscaling_group" "this" {
  name                      = "${var.name}-asg"
  max_size                  = var.max_size
  min_size                  = var.min_size
  desired_capacity          = var.desired_capacity
  vpc_zone_identifier       = var.subnet_ids

  health_check_type         = length(var.target_group_arns) > 0 ? "ELB" : "EC2"
  health_check_grace_period = var.health_check_grace_sec
  force_delete              = var.force_delete

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  termination_policies = var.termination_policies
  target_group_arns    = var.target_group_arns

  dynamic "tag" {
    for_each = merge(
      var.tags,
      var.instance_tags,
      { Name = var.name }
    )
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 90
      auto_rollback          = false
    }
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity] # avoids noisy diffs during scale
  }
}
