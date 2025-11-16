resource "aws_vpc" "secondary" {
  region               = "us-west-1"
  cidr_block           = "10.222.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

#NATGW 
resource "aws_subnet" "public_a_az1_r2" {
  vpc_id            = aws_vpc.secondary.id
  cidr_block        = "10.222.1.0/24"
  availability_zone = var.az1_r2
}
resource "aws_subnet" "public_b_az2_r2" {
  vpc_id            = aws_vpc.secondary.id
  cidr_block        = "10.222.2.0/24"
  availability_zone = var.az2_r2
}
#Web Tier -----------
resource "aws_subnet" "private_e_az1_r2" {
  vpc_id            = aws_vpc.secondary.id
  cidr_block        = "10.222.5.0/24"
  availability_zone = var.az1_r2
}
resource "aws_subnet" "private_f_az2_r2" {
  vpc_id            = aws_vpc.secondary.id
  cidr_block        = "10.222.6.0/24"
  availability_zone = var.az2_r2
}
#App Tier
resource "aws_subnet" "private_a_az1_r2" {
  vpc_id            = aws_vpc.secondary.id
  cidr_block        = "10.222.3.0/24"
  availability_zone = var.az1_r2
}
resource "aws_subnet" "private_b_az2_r2" {
  vpc_id            = aws_vpc.secondary.id
  cidr_block        = "10.222.4.0/24"
  availability_zone = var.az2_r2
}
#DB Tier
resource "aws_subnet" "private_c_az1_r2" {
  vpc_id            = aws_vpc.secondary.id
  cidr_block        = "10.222.11.0/24"
  availability_zone = var.az1_r2
}
resource "aws_subnet" "private_d_az2_r2" {
  vpc_id            = aws_vpc.secondary.id
  cidr_block        = "10.222.12.0/24"
  availability_zone = var.az2_r2
}

resource "aws_internet_gateway" "igw_r2" {
  vpc_id = aws_vpc.secondary.id
}

resource "aws_eip" "ngw_r2" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.igw_r2]
}
resource "aws_eip" "ngw2_r2" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.igw_r2]
}
resource "aws_nat_gateway" "ngw_r2" {
  allocation_id = aws_eip.ngw_r2.id
  subnet_id     = aws_subnet.public_a_az1_r2.id
  depends_on    = [aws_internet_gateway.igw_r2]
}
resource "aws_nat_gateway" "ngw2_r2" {
  allocation_id = aws_eip.ngw2_r2.id
  subnet_id     = aws_subnet.public_b_az2_r2.id
  depends_on    = [aws_internet_gateway.igw_r2]
}

resource "aws_route_table" "private_nat_rtb_r2" {
  vpc_id = aws_vpc.secondary.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw_r2.id
  }
}
resource "aws_route_table" "private_nat2_rtb_r2" {
  vpc_id = aws_vpc.secondary.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw2_r2.id
  }
}

resource "aws_route_table" "public_rtb_r2" {
  vpc_id = aws_vpc.secondary.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_r2.id
  }
}

resource "aws_route_table" "private_db_rtb_r2" {
  vpc_id = aws_vpc.secondary.id
}

resource "aws_route_table_association" "public_a_az1_r2" {
  subnet_id      = aws_subnet.public_a_az1_r2.id
  route_table_id = aws_route_table.public_rtb_r2.id
}
resource "aws_route_table_association" "public_b_az2_r2" {
  subnet_id      = aws_subnet.public_b_az2_r2.id
  route_table_id = aws_route_table.public_rtb_r2.id
}
resource "aws_route_table_association" "private_a_az1_r2" {
  subnet_id      = aws_subnet.private_a_az1_r2.id
  route_table_id = aws_route_table.private_nat_rtb_r2.id
}
resource "aws_route_table_association" "private_b_az2_r2" {
  subnet_id      = aws_subnet.private_b_az2_r2.id
  route_table_id = aws_route_table.private_nat2_rtb_r2.id
}
resource "aws_route_table_association" "private_e_az1_r2" {
  subnet_id      = aws_subnet.private_e_az1_r2.id
  route_table_id = aws_route_table.private_nat_rtb_r2.id
}
resource "aws_route_table_association" "private_f_az2_r2" {
  subnet_id      = aws_subnet.private_f_az2_r2.id
  route_table_id = aws_route_table.private_nat2_rtb_r2.id
}
resource "aws_route_table_association" "private_c_az1_r2" {
  subnet_id      = aws_subnet.private_c_az1_r2.id
  route_table_id = aws_route_table.private_db_rtb_r2.id
}
resource "aws_route_table_association" "private_d_az2_r2" {
  subnet_id      = aws_subnet.private_d_az2_r2.id
  route_table_id = aws_route_table.private_db_rtb_r2.id
}