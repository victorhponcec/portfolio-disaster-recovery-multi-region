#SSM VPC endpoint
resource "aws_vpc_endpoint" "ssm_r2" {
  vpc_id            = aws_vpc.secondary.id
  service_name      = "com.amazonaws.${var.region2}.ssm"
  vpc_endpoint_type = "Interface"
  subnet_ids = [
    aws_subnet.private_a_az1_r2.id,
    aws_subnet.private_b_az2_r2.id
  ]
  security_group_ids  = [aws_security_group.ssm_r2.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ec2messages_r2" {
  vpc_id            = aws_vpc.secondary.id
  service_name      = "com.amazonaws.${var.region2}.ec2messages"
  vpc_endpoint_type = "Interface"
  subnet_ids = [
    aws_subnet.private_a_az1_r2.id,
    aws_subnet.private_b_az2_r2.id
  ]
  security_group_ids  = [aws_security_group.ssm_r2.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ssmmessages_r2" {
  vpc_id            = aws_vpc.secondary.id
  service_name      = "com.amazonaws.${var.region2}.ssmmessages"
  vpc_endpoint_type = "Interface"
  subnet_ids = [
    aws_subnet.private_a_az1_r2.id,
    aws_subnet.private_b_az2_r2.id
  ]
  security_group_ids  = [aws_security_group.ssm_r2.id]
  private_dns_enabled = true
}

#Secrets Manager VPC Endpoint
resource "aws_vpc_endpoint" "secrets_manager_r2" {
  vpc_id            = aws_vpc.secondary.id
  service_name      = "com.amazonaws.${var.region2}.secretsmanager"
  vpc_endpoint_type = "Interface"
  subnet_ids = [
    aws_subnet.private_a_az1_r2.id,
    aws_subnet.private_b_az2_r2.id
  ]
  security_group_ids  = [aws_security_group.secrets_manager_r2.id]
  private_dns_enabled = true
}
