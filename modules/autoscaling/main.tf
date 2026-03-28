resource "aws_autoscaling_group" "this" {
  name = "webapp-asg-${var.environment}"
  desired_capacity    = 2
  max_size            = 3
  min_size            = 1

  vpc_zone_identifier = var.private_subnets

  instance_refresh {
  strategy = "Rolling"

  preferences {
    min_healthy_percentage = 50
  }
}

  launch_template {
    id = var.launch_template_id
    version = "$Latest"
  }

  target_group_arns = [var.target_group_arn]

  health_check_type = "ELB"
}

