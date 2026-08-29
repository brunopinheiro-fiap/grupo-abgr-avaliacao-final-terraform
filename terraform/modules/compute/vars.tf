# COMPUTE VARS DEFAULT VALUES

variable "ec2_ami" {
  type        = string
  default     = ""
  description = "AMI das instâncias. Vazio busca a AMI Amazon Linux 2023 mais recente."

  validation {
    condition = (
      var.ec2_ami == "" ||
      (length(var.ec2_ami) > 4 &&
      substr(var.ec2_ami, 0, 4) == "ami-")
    )
    error_message = "O valor da variável ec2_ami deve iniciar com \"ami-\" ou ser vazio para usar a AMI mais recente."
  }
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}
variable "key_name" {
  type        = string
  default     = ""
  description = "Nome do key pair EC2 para acesso SSH (ex: vockey). Vazio não associa chave."
}
variable "ssh_allowed_cidr" {
  type    = string
  default = "0.0.0.0/0"
}
variable "vpc_id" {}
variable "subnet_az1a_id" {}
variable "subnet_az1b_id" {}

variable "name_prefix" {
  type    = string
  default = "dynamicsite-lb"
}
