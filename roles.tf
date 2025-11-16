#Enable SSM on EC2
resource "aws_iam_role" "ssm_role" {
  name = "ssm_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}
resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
resource "aws_iam_instance_profile" "ssm_profile" {
  name = "SSMInstanceProfile"
  role = aws_iam_role.ssm_role.name
}

#Role for APP tier
resource "aws_iam_role" "ssm_secrets_manager_role" {
  name = "ssm-secrets-manager"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}
resource "aws_iam_policy" "secrets_manager" {
  name        = "secrets-manager"
  description = "Allow EC2 to secrets manager and ssm core"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Effect   = "Allow"
        Resource = aws_secretsmanager_secret.db_password.arn #check regional secret
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "ssm_sm_attach" {
  role       = aws_iam_role.ssm_secrets_manager_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "secrets_manager_attach" {
  role       = aws_iam_role.ssm_secrets_manager_role.name
  policy_arn = aws_iam_policy.secrets_manager.arn
}

resource "aws_iam_instance_profile" "ssm_secrets_manager_profile" {
  name = "SSMInstanceProfile-app"
  role = aws_iam_role.ssm_secrets_manager_role.name
}