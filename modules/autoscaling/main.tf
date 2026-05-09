resource "aws_autoscaling_group" "this" {
  name_prefix = "webapp-asg-${var.environment}-"
 

  desired_capacity    = 1
  max_size            = 1
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

  
   
}