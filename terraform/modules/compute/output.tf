# SECURITY INSTANCES

output "sg_id_compute" {
    value = "${aws_security_group.vpc_sg_pub.id}"
}

output "instance_a_id" {
    value = "${aws_instance.instance-a.id}"
}

output "instance_b_id" {
    value = "${aws_instance.instance-b.id}"
}

output "lb_dns_name" {
    value = "${aws_lb.ec2_lb.dns_name}"
}