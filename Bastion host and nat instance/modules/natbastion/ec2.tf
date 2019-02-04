resource "aws_instance" "terra_bastion_host" {
  instance_type          = "${var.instance_type}"
  ami                    = "${var.ami}"
  key_name               = "${var.key_name}"
  vpc_security_group_ids = ["${aws_security_group.sg_bastion.id}"]
  subnet_id              = "${aws_subnet.public_subnet.id}"
}

resource "aws_instance" "terra_private_host" {
  instance_type          = "${var.instance_type}"
  ami                    = "${var.ami}"
  key_name               = "${var.key_name}"
  vpc_security_group_ids = ["${aws_security_group.sg_private.id}"]
  subnet_id              = "${aws_subnet.private_subnet.id}"

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install httpd -y",
      "sudo systemctl start httpd",
      "sudo echo 'Hello my Universe' | sudo tee /var/www/html/index.html",
    ]

    connection {
      bastion_host        = "${aws_instance.terra_bastion_host.public_ip}"
      bastion_user        = "ec2-user"
      user                = "ec2-user"
      host                = "${self.private_ip}"
      private_key         = "${file(var.private_key)}"
    }
  }
}

resource "aws_instance" "terra_nat_instance" {
  ami                    = "ami-066f30f2afcdcdc71"
  instance_type          = "${var.instance_type}"
  key_name               = "${var.key_name}"
  vpc_security_group_ids = ["${aws_security_group.sg_nat_instance.id}"]
  subnet_id              = "${aws_subnet.public_subnet.id}"
  source_dest_check      = "false"
}
