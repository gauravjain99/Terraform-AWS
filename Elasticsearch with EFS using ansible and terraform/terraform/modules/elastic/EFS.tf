resource "aws_efs_file_system" "efs-file" {
  creation_token = "efs-file"
}

resource "aws_efs_mount_target" "alpha" {
  file_system_id = "${aws_efs_file_system.efs-file.id}"
  subnet_id      = "${aws_subnet.public_subnet.id}"
}
