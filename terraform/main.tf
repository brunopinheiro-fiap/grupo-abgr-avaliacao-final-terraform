# ORCHESTRATOR

module "network" {
source = "./modules/network"
}

module "compute" {
source = "./modules/compute"
vpc_id = "${module.network.vpc_id}"
subnet_az1a_id = "${module.network.subnet_az1a_id}"
subnet_az1b_id = "${module.network.subnet_az1b_id}"
name_prefix = "dynamicsite-lb"
}

output "lb_dns_name" {
value = "${module.compute.lb_dns_name}"
}