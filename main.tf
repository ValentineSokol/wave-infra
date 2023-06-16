provider "aws" {
  region = "eu-north-1"
}
# VPC
resource "aws_vpc" "wave_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Subnet
resource "aws_subnet" "wave_subnet" {
  vpc_id     = aws_vpc.wave_vpc.id
  cidr_block = "10.0.0.0/24"
}


# Security Group for EC2
resource "aws_security_group" "wave_ec2_security_group" {
  vpc_id = aws_vpc.wave_vpc.id

  # Inbound rules
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound rules
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "wave_ec2" {
  ami                    = "ami-0123456789abcdef0"
  instance_type          = "t2.micro"
  key_name               = "wave_ec2"
  subnet_id              = aws_subnet.wave_subnet.id
  vpc_security_group_ids = [aws_security_group.wave_ec2_security_group.id]
}

resource "aws_db_subnet_group" "wave_db_subnet_group" {
  name       = "wave-db-subnet-group"
  subnet_ids = [aws_subnet.wave_subnet.id]
}

resource "aws_db_instance" "wave_db_instance" {
  engine               = "mysql"
  instance_class       = "db.t2.micro"
  allocated_storage    = 20
  identifier           = "wave-db-instance"
  username             = var.db_username
  password             = var.db_password
  db_subnet_group_name = aws_db_subnet_group.wave_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.wave_ec2_security_group.id]
}
