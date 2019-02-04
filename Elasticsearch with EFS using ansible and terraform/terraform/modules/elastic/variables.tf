variable "region"{
  default = "ap-southeast-1"
}

variable "ami" {
  description = "ami image for the ec2 instance"
}

variable "instance_type" {
  description = "instance type for the ec2 instance"
}

variable "key_name" {
  description = "Name of the key for accessing ec2 services without .pem"
}

variable "private_key" {
  description = "path of the private key with pem"
}

variable "enable_dns_hostnames" {
  description = "True or False value and Indicates whether the instances launched in the VPC get public DNS hostnames"
}

variable "network_address_space" {
  description = "Range with cidr for VPC, biggest range"
}

variable "subnet_address_space" {
  description = "Range with cidr for VPC, subnet range"
}
