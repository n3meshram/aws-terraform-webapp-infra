resource "aws_autoscaling_group" "this" {
  name = "webapp-asg-${var.environment}"
  update_default_version = true

  desired_capacity    = 2
  max_size            = 3
  min_size            = 1

  vpc_zone_identifier = var.private_subnets

  launch_template {
    id      = var.launch_template_id
    version = "$Latest"
  }

  target_group_arns = [var.target_group_arn]

  health_check_type = "ELB"

  instance_refresh {
    strategy = "Rolling"

    triggers = ["launch_template"]

    preferences {
      min_healthy_percentage = 50
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}