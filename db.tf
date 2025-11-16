resource "aws_db_subnet_group" "rds_subnet" {
  name       = "rds-subnet"
  subnet_ids = [aws_subnet.private_c_az1.id, aws_subnet.private_d_az2.id]
}

resource "aws_db_instance" "rds" {
  db_name                = "dbtest"
  allocated_storage      = 10
  engine                 = "mysql"
  instance_class         = "db.t3.micro"
  username               = "admin"
  password               = random_password.db.result
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.db.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet.name
  publicly_accessible    = false
}

# replica to Region 2
resource "aws_db_subnet_group" "rds_subnet_region_b" {
  provider = aws.west1
  name     = "rds-subnet-r2"
  subnet_ids = [
    aws_subnet.private_c_az1_r2.id,
    aws_subnet.private_d_az2_r2.id
  ]
}

resource "aws_db_instance" "rds_replica" {
  provider               = aws.west1
  replicate_source_db    = aws_db_instance.rds.arn
  instance_class         = "db.t3.micro"
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.db_r2.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_region_b.name
}