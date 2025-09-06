resource "aws_launch_template" "this" {
  name_prefix             = "${var.name}-lt-"
  image_id                = var.ami_id
  instance_type           = var.instance_type
  key_name                = var.key_name
  vpc_security_group_ids  = var.security_group_ids
  update_default_version  = true
  ebs_optimized           = var.ebs_optimized
  disable_api_termination = var.disable_api_termination

  user_data = (
    length(var.user_data_base64) > 0 ? var.user_data_base64 :
    length(var.user_data)        > 0 ? base64encode(var.user_data) :
    null
  )


  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  monitoring {
    enabled = var.detailed_monitoring
  }

  dynamic "iam_instance_profile" {
    for_each = var.iam_instance_profile_name == null ? [] : [1]
    content {
      name = var.iam_instance_profile_name
    }
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

resource "aws_autoscaling_group" "this" {
  name                      = "${var.name}-asg"
  max_size                  = var.max_size
  min_size                  = var.min_size
  desired_capacity          = var.desired_capacity
  vpc_zone_identifier       = var.subnet_ids
  health_check_type         = length(var.target_group_arns) > 0 ? "ELB" : "EC2"
  health_check_grace_period = var.health_check_grace_sec
  force_delete              = var.force_delete
  termination_policies      = var.termination_policies

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  target_group_arns = var.target_group_arns

  dynamic "tag" {
    for_each = merge(var.tags, { Name = var.name })
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

  capacity_rebalance = var.enable_capacity_rebalance

  lifecycle {
    create_before_destroy = true
    ignore_changes = [desired_capacity]
  }
}
