resource "aws_security_group" "alb_sg" {
  name   = "webapp-${var.environment}-alb-sg"
  description = "Security group for ALB allowing HTTP traffic from internet"
  vpc_id = var.vpc_id
  
#tfsec:ignore:aws-ec2-no-public-ingress-sgr
  ingress {
    description = "Allow HTTP traffic from internet to ALB"

    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # allow all outbound (keep simple for now)
  egress {
    description     = "Allow HTTP traffic from ALB to EC2 instances"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ec2_sg" {
  name   = "webapp-${var.environment}-ec2-sg"
  description = "Security group for EC2 allowing traffic from ALB"
  vpc_id = var.vpc_id


  tags = {
    Name = "webapp-${var.environment}-ec2-sg"
  }
}

resource "aws_security_group_rule" "alb_to_ec2" {
   description     = "Allow HTTP traffic from ALB"
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"

  security_group_id        = aws_security_group.ec2_sg.id
  source_security_group_id = aws_security_group.alb_sg.id
}