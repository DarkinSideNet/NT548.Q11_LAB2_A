variable "vpc_id" {
  description = "ID của VPC để gắn Security Group"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR được phép SSH vào Public EC2 (ví dụ 1.2.3.4/32)"
  type        = string
}