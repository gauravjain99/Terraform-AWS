resource "aws_launch_configuration" "launch" {
  name_prefix     = "terraform-lc-example-"
  image_id        = "${var.ami}"
  instance_type   = "t2.micro"
  key_name        = "${var.key_name}"
  security_groups = ["${aws_security_group.cloudsns.id}"]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "bar" {
  name                 = "terraform-asg-example"
  launch_configuration = "${aws_launch_configuration.launch.name}"
  vpc_zone_identifier  = ["${aws_subnet.subnet1.id}", "${aws_subnet.subnet2.id}"]
  min_size             = 2
  max_size             = 6
  health_check_type    = "EC2"
}

resource "aws_autoscaling_policy" "increase" {
  name                   = "to_increase"
  scaling_adjustment     = 2
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.bar.name}"
}

resource "aws_autoscaling_policy" "decrease" {
  name                   = "to_decrease"
  scaling_adjustment     = -2
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.bar.name}"
}

resource "aws_cloudwatch_metric_alarm" "increase" {
  alarm_name          = "greater"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"

  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.bar.name}"
  }

  threshold         = "10"
  ok_actions        = ["${aws_sns_topic.messagesms.arn}"]
  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = ["${aws_autoscaling_policy.increase.arn}", "${aws_sns_topic.messagesms.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "decrease" {
  alarm_name          = "lesser"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "6"

  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.bar.name}"
  }

  ok_actions        = ["${aws_sns_topic.messagesms.arn}"]
  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = ["${aws_autoscaling_policy.decrease.arn}", "${aws_sns_topic.messagesms.arn}"]
}

resource "aws_sns_topic" "messagesms" {
  name = "cloud"
}
