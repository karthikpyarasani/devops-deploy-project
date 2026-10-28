variable "region" {
  description = "AWS region"
  default     = "eu-north-1"
}

variable "instance_type" {
  description = "EC2 size"
  default     = "t3.micro"
}

variable "key_name" {
  description = "Existing EC2 key pair for SSH"
  default     = "devops-new-key"
}

variable "my_ip" {
  description = "My IP for SSH access"
  default     = "86.149.128.146/32"
}
