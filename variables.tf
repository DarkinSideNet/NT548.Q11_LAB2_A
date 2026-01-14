variable "aws_region" {
  description = "AWS region để triển khai tài nguyên"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS CLI profile (để trống nếu dùng env vars/role)"
  type        = string
  default     = null
}

variable "allowed_ssh_cidr" {
  description = "CIDR được phép SSH vào Public EC2 (ví dụ 1.2.3.4/32)"
  type        = string
}

variable "key_name" {
  description = "Tên EC2 Key Pair có sẵn trên AWS"
  type        = string
}

variable "ami_id" {
  description = "AMI ID cho EC2 instances (ví dụ Ubuntu/Amazon Linux)"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}
