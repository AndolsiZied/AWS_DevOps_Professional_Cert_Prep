variable "region" {
  default = "eu-west-3"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "private_subnet_cidr_1" {
  default = "10.0.1.0/24"
}

variable "private_subnet_cidr_2" {
  default = "10.0.2.0/24"
}

variable "ec2_instance_type" {
  default = "t3.micro"
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  default     = "ami-0f38b927e6597da05"
}

variable "ip_white_list" {
  description = "list of ip allowed to call th aLB"
  type        = list(string)
  default     = ["88.166.216.98/32"]
}

variable "notification_email" {
  default = "zandolsi@acegik.fr"
}
