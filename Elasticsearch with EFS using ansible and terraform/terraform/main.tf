# Providers

provider "aws" {
  region = "${var.region}"
}

module "elastic" {
  source                = "modules/elastic/"
  private_key           = "${var.private_key}"
  ami                   = "${var.ami}"
  instance_type         = "${var.instance_type}"
  key_name              = "${var.key_name}"
  network_address_space = "${var.network_address_space}"
  enable_dns_hostnames  = "${var.enable_dns_hostnames}"
  subnet_address_space  = "${var.subnet_address_space}"
}
