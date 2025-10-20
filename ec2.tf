resource "aws_instance" "tf_server" {
  ami                         = "ami-02d26659fd82cf299" # change according to region
  instance_type               = "t3.micro"
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id] # associate security group
  associate_public_ip_address = true
  key_name                    = "terraform_ec2_nodejs" # private aws key name
  
  user_data                   = <<-EOF
                                #!/bin/bash

                                # Git clone 
                                git clone https://github.com/verma-kunal/nodejs-mysql.git /home/ubuntu/nodejs-mysql
                                cd /home/ubuntu/nodejs-mysql

                                # install nodejs
                                sudo apt update -y
                                sudo apt install -y nodejs npm

                                # edit env vars
                                echo "DB_HOST=${aws_db_instance.tf_rds_instance.endpoint}" | sudo tee .env
                                echo "DB_USER=${aws_db_instance.tf_rds_instance.username}" | sudo tee -a .env
                                sudo echo "DB_PASS=${aws_db_instance.tf_rds_instance.password}" | sudo tee -a .env
                                echo "DB_NAME=${aws_db_instance.tf_rds_instance.db_name}" | sudo tee -a .env
                                echo "TABLE_NAME=users" | sudo tee -a .env
                                echo "PORT=3000" | sudo tee -a .env

                                # start server
                                npm install
                                EOF
 
  depends_on                  = [aws_s3_object.s3_object_barath] # attach s3 bucket
  user_data_replace_on_change = true
  tags = {
    Name = "nodejs-server"
  }
}

# security group
resource "aws_security_group" "ec2_sg" {
  name        = "nodejs_sg"
  description = "Allow SSH and HTTP traffic"
  vpc_id      = "vpc-0919fdcf4f9f14b0f" # default VPC

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # allow from all IPs
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "TCP"
    from_port   = 3000 # for nodejs app
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# output
output "ec2_public_ip" {
  value = aws_instance.tf_server.public_ip
}