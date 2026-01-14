variable "public_subnet_id" {
  type = string
}

variable "private_subnet_id" {
  type = string
}

variable "public_sg_id" {
  type = string
}

variable "private_sg_id" {
  type = string
}

variable "ami_id" {
  description = "AMI ID cho EC2"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Tên EC2 Key Pair"
  type        = string
}