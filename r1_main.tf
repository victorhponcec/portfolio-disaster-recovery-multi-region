resource "aws_vpc" "main" {
  cidr_block           = "10.111.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

#NATGW 
resource "aws_subnet" "public_a_az1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.111.1.0/24"
  availability_zone = var.az1
}
resource "aws_subnet" "public_b_az2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.111.2.0/24"
  availability_zone = var.az2
}
#Web Tier -----------
resource "aws_subnet" "private_e_az1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.111.5.0/24"
  availability_zone = var.az1
}
resource "aws_subnet" "private_f_az2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.111.6.0/24"
  availability_zone = var.az2
}
#App Tier
resource "aws_subnet" "private_a_az1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.111.3.0/24"
  availability_zone = var.az1
}
resource "aws_subnet" "private_b_az2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.111.4.0/24"
  availability_zone = var.az2
}
#DB Tier
resource "aws_subnet" "private_c_az1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.111.11.0/24"
  availability_zone = var.az1
}
resource "aws_subnet" "private_d_az2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.111.12.0/24"
  availability_zone = var.az2
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_eip" "ngw" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.igw]
}
resource "aws_eip" "ngw2" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.igw]
}
resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.ngw.id
  subnet_id     = aws_subnet.public_a_az1.id
  depends_on    = [aws_internet_gateway.igw]
}
resource "aws_nat_gateway" "ngw2" {
  allocation_id = aws_eip.ngw2.id
  subnet_id     = aws_subnet.public_b_az2.id
  depends_on    = [aws_internet_gateway.igw]
}

resource "aws_route_table" "private_nat_rtb" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.id
  }
}
resource "aws_route_table" "private_nat2_rtb" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw2.id
  }
}

resource "aws_route_table" "public_rtb" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table" "private_db_rtb" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table_association" "public_a_az1" {
  subnet_id      = aws_subnet.public_a_az1.id
  route_table_id = aws_route_table.public_rtb.id
}
resource "aws_route_table_association" "public_b_az2" {
  subnet_id      = aws_subnet.public_b_az2.id
  route_table_id = aws_route_table.public_rtb.id
}
resource "aws_route_table_association" "private_a_az1" {
  subnet_id      = aws_subnet.private_a_az1.id
  route_table_id = aws_route_table.private_nat_rtb.id
}
resource "aws_route_table_association" "private_b_az2" {
  subnet_id      = aws_subnet.private_b_az2.id
  route_table_id = aws_route_table.private_nat2_rtb.id
}
resource "aws_route_table_association" "private_e_az1" {
  subnet_id      = aws_subnet.private_e_az1.id
  route_table_id = aws_route_table.private_nat_rtb.id
}
resource "aws_route_table_association" "private_f_az2" {
  subnet_id      = aws_subnet.private_f_az2.id
  route_table_id = aws_route_table.private_nat2_rtb.id
}
resource "aws_route_table_association" "private_c_az1" {
  subnet_id      = aws_subnet.private_c_az1.id
  route_table_id = aws_route_table.private_db_rtb.id
}
resource "aws_route_table_association" "private_d_az2" {
  subnet_id      = aws_subnet.private_d_az2.id
  route_table_id = aws_route_table.private_db_rtb.id
}