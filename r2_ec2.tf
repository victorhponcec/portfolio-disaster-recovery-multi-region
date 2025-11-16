resource "aws_instance" "break_glass_r2" {
  ami                         = var.amazon_linux_2023
  instance_type               = "t2.micro"
  security_groups             = [aws_security_group.break_glass_r2.id]
  subnet_id                   = aws_subnet.public_a_az1_r2.id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.ec2_key_r2.key_name
}

resource "tls_private_key" "pkey_r2" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "local_file" "private_key_pem_r2" {
  content         = tls_private_key.pkey_r2.private_key_pem
  filename        = "AWSKeySSH.pem"
  file_permission = "0400"
}
resource "aws_key_pair" "ec2_key_r2" {
  key_name   = "AWSKeySSH"
  public_key = tls_private_key.pkey_r2.public_key_openssh

  lifecycle {
    ignore_changes = [key_name]
  }
}