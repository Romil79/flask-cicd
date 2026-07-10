provider "aws" {
  region = "ap-south-1"
}

# Fetch latest Amazon Linux 2023 AMI automatically
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# Upload your local SSH public key to AWS
resource "aws_key_pair" "flask_key" {
  key_name   = "flask-cicd-key"
  public_key = file("~/.ssh/flask-cicd-key.pub")
}

# Security group — controls what traffic can reach the server
resource "aws_security_group" "flask_sg" {
  name        = "flask-cicd-sg"
  description = "Allow SSH and Flask app traffic"

  # SSH access — so you can log in
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Flask app port
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "flask-cicd-sg"
    Project = "flask-cicd"
  }
}

# EC2 instance
resource "aws_instance" "flask_server" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.flask_key.key_name
  vpc_security_group_ids = [aws_security_group.flask_sg.id]

  # Runs automatically when server first boots
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y docker
    systemctl start docker
    systemctl enable docker
    usermod -aG docker ec2-user
    docker pull romil79/flask-cicd:latest
    docker run -d -p 5000:5000 --name flask-app romil79/flask-cicd:latest
  EOF

  tags = {
    Name    = "flask-cicd-server"
    Project = "flask-cicd"
  }
}

output "instance_public_ip" {
  value       = aws_instance.flask_server.public_ip
  description = "Public IP — visit http://<this-ip>:5000"
}

output "ssh_command" {
  value       = "ssh -i ~/.ssh/flask-cicd-key ec2-user@${aws_instance.flask_server.public_ip}"
  description = "Run this to SSH into your server"
}