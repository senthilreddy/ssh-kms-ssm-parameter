resource "aws_launch_template" "this" {
  name_prefix   = "${var.name}-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = var.security_group_ids
  update_default_version = true

  user_data = var.user_data_base64 != "" ? var.user_data_base64 : base64encode(var.user_data)

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tag_specifications {
    resource_type = "instance"
    tags          = merge(var.tags, { "Name" = var.name })
  }

  tag_specifications {
    resource_type = "volume"
    tags          = var.tags
  }

  lifecycle { create_before_destroy = true }
}

resource "aws_autoscaling_group" "this" {
  name                      = "${var.name}-asg"
  max_size                  = var.max_size
  min_size                  = var.min_size
  desired_capacity          = var.desired_capacity
  vpc_zone_identifier       = var.subnet_ids
  health_check_type         = var.health_check_type
  health_check_grace_period = var.health_check_grace_sec
  force_delete              = var.force_delete

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  termination_policies = var.termination_policies
  target_group_arns    = var.target_group_arns

  dynamic "tag" {
    for_each = merge(var.tags, { "Name" = var.name })
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle { create_before_destroy = true }
}
