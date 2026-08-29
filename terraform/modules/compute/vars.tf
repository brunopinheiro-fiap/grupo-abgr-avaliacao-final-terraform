# COMPUTE VARS DEFAULT VALUES

variable "ec2_ami" {
    type    = string
    default = "ami-0332d564d76dbd8d6"

    validation {
        condition = (
            length(var.ec2_ami) > 4 &&
            substr(var.ec2_ami, 0, 4) == "ami-"
        )
        error_message = "O valor da variável ec2_ami deve iniciar com \"ami-\"."
    }
}

variable "instance_type" {
    type    = string
    default = "t2.micro"
}
variable "ssh_allowed_cidr" {
    type    = string
    default = "0.0.0.0/0"
}
variable "vpc_id" {}
variable "subnet_az1a_id" {}
variable "subnet_az1b_id" {}

variable "name_prefix" {
    type = string
    default = "dynamicsite-lb"
}