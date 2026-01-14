# modules/security_groups/main.tf

# Public Security Group: Chỉ cho phép SSH từ IP của bạn 
resource "aws_security_group" "public_sg" {
  name   = "public-ssh-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Private Security Group: Chỉ cho phép SSH từ Public Instance [cite: 27]
resource "aws_security_group" "private_sg" {
  name   = "private-ssh-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.public_sg.id] # Chỉ nhận từ Public SG [cite: 27]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Default Security Group (theo yêu cầu bài): baseline SG cho VPC
resource "aws_security_group" "default_sg" {
  name        = "default-baseline-sg"
  description = "Default/baseline security group for this VPC"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}