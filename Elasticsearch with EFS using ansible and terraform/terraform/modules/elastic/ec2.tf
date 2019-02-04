resource "aws_instance" "node1" {
  instance_type          = "${var.instance_type}"
  ami                    = "${var.ami}"
  key_name               = "${var.key_name}"
  vpc_security_group_ids = ["${aws_security_group.elastic.id}", "${aws_vpc.elasticvpc.default_security_group_id}"]
  subnet_id              = "${aws_subnet.public_subnet.id}"

  provisioner "local-exec" {
#    command = "echo ${aws_instance.node1.public_ip} >> ../ansible/hosts"
     command =  "${element(aws_instance.node1.*.public_ip, count.index)}" 
  }

  connection{
    type = "ssh"
    user = "ec2-user"
    private_key = "${file(var.private_key)}"
  }

  provisioner "remote-exec"{
    inline = [
        "sudo mkdir efs",
        "sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${aws_efs_file_system.efs-file.id}.efs.${var.region }.amazonaws.com:/ efs"
    ]
  }
}

# resource "aws_instance" "node2" {
#   instance_type          = "${var.instance_type}"
#   ami                    = "${var.ami}"
#   key_name               = "${var.key_name}"
#   vpc_security_group_ids = ["${aws_security_group.elastic.id}", "${aws_vpc.elasticvpc.default_security_group_id}"]
#   subnet_id              = "${aws_subnet.public_subnet.id}"
#
#   provisioner "local-exec" {
#     command = "echo ${aws_instance.node2.public_ip} >> ../ansible/hosts"
#   }
#
#   connection{
#     type = "ssh"
#     user = "ec2-user"
#     private_key = "${file(var.private_key)}"
#   }
#
#   provisioner "remote-exec"{
#     inline = [
#         "sudo mkdir efs",
#         "sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${aws_efs_file_system.efs-file.id}.efs.${var.region}.amazonaws.com:/ efs"
#     ]
#   }
# }
#
# resource "aws_instance" "node3" {
#   instance_type          = "${var.instance_type}"
#   ami                    = "${var.ami}"
#   key_name               = "${var.key_name}"
#   vpc_security_group_ids = ["${aws_security_group.elastic.id}", "${aws_vpc.elasticvpc.default_security_group_id}"]
#   subnet_id              = "${aws_subnet.public_subnet.id}"
#
#   provisioner "local-exec" {
#     command = "echo ${aws_instance.node3.public_ip} >> ../ansible/hosts"
#   }
#
#   connection{
#     type = "ssh"
#     user = "ec2-user"
#     private_key = "${file(var.private_key)}"
#   }
#
#   provisioner "remote-exec"{
#     inline = [
#         "sudo mkdir efs",
#         "sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${aws_efs_file_system.efs-file.id}.efs.${var.region}.amazonaws.com:/ efs"
#     ]
#   }
# }
