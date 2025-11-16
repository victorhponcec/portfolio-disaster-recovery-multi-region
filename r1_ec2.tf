resource "aws_instance" "break_glass" {
  ami                         = var.amazon_linux_2023
  instance_type               = "t2.micro"
  security_groups             = [aws_security_group.break_glass.id]
  subnet_id                   = aws_subnet.public_a_az1.id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.ec2_key.key_name
}

resource "tls_private_key" "pkey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "local_file" "private_key_pem" {
  content         = tls_private_key.pkey.private_key_pem
  filename        = "AWSKeySSH.pem"
  file_permission = "0400"
}
resource "aws_key_pair" "ec2_key" {
  key_name   = "AWSKeySSH"
  public_key = tls_private_key.pkey.public_key_openssh

  lifecycle {
    ignore_changes = [key_name]
  }
}