provider "aws" {
  region = "us-west-2"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

resource "aws_subnet" "subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "main-subnet"
  }
}

resource "aws_security_group" "main_sg" {
  vpc_id = aws_vpc.main.id
  description = "Allow HTTP and SSH"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["<YOUR_CLIENT_IP>/32"] # Replace <YOUR_CLIENT_IP> with your actual IP address
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["<YOUR_CLIENT_IP>/32"] # Replace <YOUR_CLIENT_IP> with your actual IP address
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "main-sg"
  }
}

resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0" # Amazon Linux 2 AMI
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.subnet.id
  security_groups = [aws_security_group.main_sg.name]

  user_data = <<-EOF
                #!/bin/bash
                yum update -y
                yum install -y httpd python3 git docker
                amazon-linux-extras install ansible2 -y
                systemctl start httpd
                systemctl enable httpd

                # Clone the Flask app repository
                git clone https://github.com/georgezengin/AWS-EC2-UserData-Sample.git/flask-app.git /var/www/flask-app
                cd /var/www/flask-app

                # Install Flask and other dependencies
                pip3 install flask

                # Start the Flask app
                FLASK_APP=app.py flask run --host=0.0.0.0 --port=80
                EOF

  tags = {
    Name = "web-instance"
  }
}
