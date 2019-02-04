data "aws_availability_zones" "zone_id" {}

resource aws_vpc "natvpc" {
  cidr_block           = "${var.network_address_space}"
  enable_dns_hostnames = "${var.enable_dns_hostnames}"
}

resource "aws_internet_gateway" "natigw" {
  vpc_id = "${aws_vpc.natvpc.id}"
}

resource "aws_subnet" "public_subnet" {
  cidr_block              = "${var.subnet1_address_space}"
  vpc_id                  = "${aws_vpc.natvpc.id}"
  map_public_ip_on_launch = "true"
  availability_zone       = "${data.aws_availability_zones.zone_id.names[0]}"
}

resource "aws_subnet" "private_subnet" {
  cidr_block              = "${var.subnet2_address_space}"
  vpc_id                  = "${aws_vpc.natvpc.id}"
  map_public_ip_on_launch = "false"
  availability_zone       = "${data.aws_availability_zones.zone_id.names[1]}"
}

resource "aws_route_table" "public_route_table" {
  vpc_id = "${aws_vpc.natvpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.natigw.id}"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = "${aws_vpc.natvpc.id}"

  route {
    cidr_block  = "0.0.0.0/0"
    instance_id = "${aws_instance.terra_nat_instance.id}"
  }
}

resource "aws_route_table_association" "table_public" {
  subnet_id      = "${aws_subnet.public_subnet.id}"
  route_table_id = "${aws_route_table.public_route_table.id}"
}

resource "aws_route_table_association" "table_private" {
  subnet_id      = "${aws_subnet.private_subnet.id}"
  route_table_id = "${aws_route_table.private_route_table.id}"
}

# Security groups

resource "aws_security_group" "sg_bastion" {
  name   = "sg_bastion"
  vpc_id = "${aws_vpc.natvpc.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "sg_nat_instance" {
  name   = "sg_nat_instance"
  vpc_id = "${aws_vpc.natvpc.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.1.2.0/24"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.1.2.0/24"]
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["10.1.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "sg_private" {
  name   = "sg_private"
  vpc_id = "${aws_vpc.natvpc.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.1.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}
