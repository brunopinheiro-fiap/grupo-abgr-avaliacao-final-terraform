# NETWORK VARS: DEFAULT VALUES

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "subnet_az1a_cidr" {
  type    = string
  default = "10.0.10.0/24"
}

variable "subnet_az1b_cidr" {
  type    = string
  default = "10.0.20.0/24"
}