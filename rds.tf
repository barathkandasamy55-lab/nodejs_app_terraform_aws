# RDS configuration
resource "aws_db_instance" "tf_rds_instance" {
  allocated_storage      = 10
  db_name                = "barath_demo" # name of database to create
  identifier             = "nodejs-rds"
  engine                 = "mysql"
  engine_version         = "8.0.42"
  instance_class         = "db.t3.micro"
  username               = "admin"
  password               = "#Barath2003"
  parameter_group_name   = "default.mysql8.0"
  vpc_security_group_ids = [aws_security_group.rds_sg.id] # attach RDS security group
  skip_final_snapshot    = true
  publicly_accessible    = true
}
resource "aws_security_group" "rds_sg" {
  vpc_id      = "vpc-0919fdcf4f9f14b0f" # default VPC.
  name        = "allow_mysql"
  description = "Allow MySQL traffic"

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    cidr_blocks     = ["103.185.238.225/32"]           # local IP address
    security_groups = [aws_security_group.ec2_sg.id] # Allow traffic from EC2 security group
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allow all outbound traffic
  }
}
output "rds_endpoint" {
value = aws_db_instance.tf_rds_instance.endpoint
}