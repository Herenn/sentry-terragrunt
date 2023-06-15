variable "email" {
  description = "Email for creating a Sentry user"
}

variable "password" {
  description = "Password for creating a Sentry user"
}

variable "subnet_id" {
  description = "Subnet ID for EC2 Instance"
}

variable "instance_type" {
  description = "Instance Type for EC2 Instance"
}

variable "key_name" {
  description = "Private Key Name for EC2 Instance"
}