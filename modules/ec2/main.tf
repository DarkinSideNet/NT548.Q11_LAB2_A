# modules/ec2/main.tf

# Public Instance
resource "aws_instance" "public_node" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.public_sg_id]
  key_name               = var.key_name
  associate_public_ip_address = true
  tags                   = { Name = "Public-EC2" }
}

# Private Instance
resource "aws_instance" "private_node" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_id
  vpc_security_group_ids = [var.private_sg_id]
  key_name               = var.key_name
  tags                   = { Name = "Private-EC2" }
}