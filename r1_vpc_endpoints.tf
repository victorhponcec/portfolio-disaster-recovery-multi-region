#SSM VPC endpoint
resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region1}.ssm"
  vpc_endpoint_type = "Interface"
  subnet_ids = [
    aws_subnet.private_a_az1.id,
    aws_subnet.private_b_az2.id
  ]
  security_group_ids  = [aws_security_group.ssm.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region1}.ec2messages"
  vpc_endpoint_type = "Interface"
  subnet_ids = [
    aws_subnet.private_a_az1.id,
    aws_subnet.private_b_az2.id
  ]
  security_group_ids  = [aws_security_group.ssm.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region1}.ssmmessages"
  vpc_endpoint_type = "Interface"
  subnet_ids = [
    aws_subnet.private_a_az1.id,
    aws_subnet.private_b_az2.id
  ]
  security_group_ids  = [aws_security_group.ssm.id]
  private_dns_enabled = true
}

#Secrets Manager VPC Endpoint
resource "aws_vpc_endpoint" "secrets_manager" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region1}.secretsmanager"
  vpc_endpoint_type = "Interface"
  subnet_ids = [
    aws_subnet.private_a_az1.id,
    aws_subnet.private_b_az2.id
  ]
  security_group_ids  = [aws_security_group.secrets_manager.id]
  private_dns_enabled = true
}
