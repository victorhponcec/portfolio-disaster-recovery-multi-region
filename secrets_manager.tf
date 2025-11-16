resource "aws_secretsmanager_secret" "db_password" {
  name        = "db-password-v8"
  description = "Database Password"
}

resource "random_password" "db" {
  length  = 14
  special = true
}

resource "aws_secretsmanager_secret_version" "db_password_v1" {
  secret_id = aws_secretsmanager_secret.db_password.id
  secret_string = jsonencode({
    username = "admin"
    password = random_password.db.result
  })
}