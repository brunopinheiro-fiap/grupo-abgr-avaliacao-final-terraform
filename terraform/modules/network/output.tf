# NETWORK OUTPUT

output "vpc_id" {
    value = "${aws_vpc.vpc.id}"
}

output "subnet_az1a_id" {
    value = "${aws_subnet.sn_pub_az1a.id}"
}

output "subnet_az1b_id" {
    value = "${aws_subnet.sn_pub_az1b.id}"
}