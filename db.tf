### Resources for the RDS database

resource "random_password" "db" {
  length = 32
}


resource "aws_db_subnet_group" "main" {
  name       = "main_subnet_group"
  subnet_ids = [ aws_subnet.rds_subnet1.id, aws_subnet.rds_subnet2.id ]
}

resource "aws_db_parameter_group" "main" {
  name   = "main-parameter-group"
  family = "postgres13"
  parameter {
    name  = "log_connections"
    value = "1"
  }
}

resource "aws_db_instance" "main" {
  apply_immediately = true
  engine            = "postgres"
  engine_version    = "13"

  allocated_storage = 5 # minimum = 5?
  instance_class    = "db.t3.micro"
  storage_type      = "standard"

  multi_az             = false
  availability_zone    = aws_subnet.rds_subnet1.availability_zone
  db_subnet_group_name = aws_db_subnet_group.main.name
  parameter_group_name = aws_db_parameter_group.main.name

  username = data.aws_ssm_parameter.db_user.value
  password = random_password.db.result
  name     = "tagioalisi"
}
