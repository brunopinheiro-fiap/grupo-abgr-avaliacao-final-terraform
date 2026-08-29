# RESOURCE: SECURITY GROUP
resource "aws_security_group" "vpc_sg_pub" {
  vpc_id = var.vpc_id
  tags = {
    Name = "${var.name_prefix}-sg"
  }
  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
  }
  ingress {
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = "8"
    to_port     = "0"
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

# DATA: AMI (Amazon Linux 2023 mais recente - usado quando var.ec2_ami está vazio)
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# RESOURCE: EC2
resource "aws_instance" "instance-a" {
  ami                    = var.ec2_ami != "" ? var.ec2_ami : data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_az1a_id
  vpc_security_group_ids = [aws_security_group.vpc_sg_pub.id]
  user_data              = file("${path.module}/scripts/user_data.sh")
  key_name               = var.key_name != "" ? var.key_name : null
  tags = {
    Name = "${var.name_prefix}-ec2-1a"
  }
}

resource "aws_instance" "instance-b" {
  ami                    = var.ec2_ami != "" ? var.ec2_ami : data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_az1b_id
  vpc_security_group_ids = [aws_security_group.vpc_sg_pub.id]
  user_data              = file("${path.module}/scripts/user_data.sh")
  key_name               = var.key_name != "" ? var.key_name : null
  tags = {
    Name = "${var.name_prefix}-ec2-1b"
  }
}

# RESOURCE: LOAD BALANCER TARGET GROUP
resource "aws_lb_target_group" "ec2_lb_tg" {
  name     = "ec2-lb-tg"
  protocol = "HTTP"
  port     = "80"
  vpc_id   = var.vpc_id
}

resource "aws_lb_target_group_attachment" "ec2_lb_tg-instance_a" {
  target_group_arn = aws_lb_target_group.ec2_lb_tg.arn
  target_id        = aws_instance.instance-a.id
  port             = 80
  depends_on       = [aws_instance.instance-a]
}

resource "aws_lb_target_group_attachment" "ec2_lb_tg-instance_b" {
  target_group_arn = aws_lb_target_group.ec2_lb_tg.arn
  target_id        = aws_instance.instance-b.id
  port             = 80
  depends_on       = [aws_instance.instance-b]
}

# RESOURCE: LOAD BALANCER
resource "aws_lb" "ec2_lb" {
  name               = "${var.name_prefix}-lb"
  load_balancer_type = "application"
  subnets            = [var.subnet_az1a_id, var.subnet_az1b_id]
  security_groups    = [aws_security_group.vpc_sg_pub.id]
  tags = {
    Name = "${var.name_prefix}-lb"
  }
}

resource "aws_lb_listener" "ec2_lb_listener" {
  protocol          = "HTTP"
  port              = "80"
  load_balancer_arn = aws_lb.ec2_lb.arn
  depends_on        = [aws_lb.ec2_lb]
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ec2_lb_tg.arn
  }
}
