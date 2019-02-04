# Providers

provider "aws"{
  region = "${var.region}"
}


module "aws_complete" {
  source = "modules/play/"
  private_key = "${var.private_key}"
  ami = "${var.ami}"
  instance_type = "${var.instance_type}"
  key_name = "${var.key_name}"
  network_address_space = "${var.network_address_space}"
  enable_dns_hostnames = "${var.enable_dns_hostnames}"
  subnet1_address_space = "${var.subnet1_address_space}"
  subnet2_address_space = "${var.subnet2_address_space}"
}
