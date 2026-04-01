resource "aws_iam_role" "ec2_ssm_role" {
  name = "ec2_ssm_role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"

        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy" "ssm_parameter_access" {
  name = "ssm-parameter-access-${var.environment}"
  role = aws_iam_role.ec2_ssm_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter"
        ]
        Resource = "arn:aws:ssm:ap-south-1:${data.aws_caller_identity.current.account_id}:parameter/${var.environment}/app/password"
      }
    ]
  })
}

data "aws_caller_identity" "current" {}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-ssm-profile-${var.environment}"
  role = aws_iam_role.ec2_ssm_role.name
}

data "aws_caller_identity" "current" {}

resource "aws_iam_role_policy" "secrets_access" {
  name = "secrets-access-${var.environment}"
  role = aws_iam_role.ec2_ssm_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = "arn:aws:secretsmanager:ap-south-1:${data.aws_caller_identity.current.account_id}:secret:/${var.environment}/app/password*"
      }
    ]
  })
}