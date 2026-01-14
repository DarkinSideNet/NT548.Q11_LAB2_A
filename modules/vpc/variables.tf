variable "vpc_cidr" {
  description = "CIDR cho VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR cho Public Subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR cho Private Subnet"
  type        = string
  default     = "10.0.2.0/24"
}
