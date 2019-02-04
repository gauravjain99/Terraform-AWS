data "aws_availability_zones" "no_of_zones" {}


resource "aws_vpc" "vpc"{
  cidr_block = "${var.network_address_space}"
  enable_dns_hostnames = "${var.enable_dns_hostnames}"
}

resource "aws_internet_gateway" "net_gate"{
	vpc_id = "${aws_vpc.vpc.id}"
}

resource "aws_subnet" "subnet1" {
	cidr_block = "${var.subnet1_address_space}"
	vpc_id = "${aws_vpc.vpc.id}"
	map_public_ip_on_launch = "true"
	availability_zone = "${data.aws_availability_zones.no_of_zones.names[0]}"
}

resource "aws_subnet" "subnet2" {
	cidr_block = "${var.subnet2_address_space}"
	vpc_id = "${aws_vpc.vpc.id}"
	map_public_ip_on_launch = "true"
	availability_zone = "${data.aws_availability_zones.no_of_zones.names[1]}"
}

# Routing

resource "aws_route_table" "rtb"{
	vpc_id = "${aws_vpc.vpc.id}"

route {
	cidr_block = "0.0.0.0/0"
	gateway_id = "${aws_internet_gateway.net_gate.id}"
	}
}

resource "aws_route_table_association" "rta-subnet1" {
	subnet_id = "${aws_subnet.subnet1.id}"
	route_table_id = "${aws_route_table.rtb.id}"
}

resource "aws_route_table_association" "rta-subnet2"{
	subnet_id = "${aws_subnet.subnet2.id}"
	route_table_id = "${aws_route_table.rtb.id}"
}

# AWS security groups

resource "aws_security_group" "cloudsns"{
	name = "cloudsns"
	vpc_id = "${aws_vpc.vpc.id}"

	# SSH access from anywhere

	ingress{
		from_port = 22
		to_port = 22
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
		}

	ingress{
		from_port = 80
		to_port = 80
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
		}

	egress{
		from_port = 0
		to_port = 0
		protocol = -1
		cidr_blocks = ["0.0.0.0/0"]
		}
}

resource "aws_security_group" "elbsg" {
	name = "apache_elb_sg"
	vpc_id = "${aws_vpc.vpc.id}"


	ingress {
		from_port = 80
		to_port = 80
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
		}

	egress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
		}
}
