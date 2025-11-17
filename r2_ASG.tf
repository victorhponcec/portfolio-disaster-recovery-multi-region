#ASG WEB
resource "aws_launch_template" "web_r2" {
  provider = aws.west1
  name_prefix   = "web-r2"
  image_id      = var.amazon_linux_2023_uswest1
  instance_type = "t2.micro"
  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.web_r2.id]
  }
  iam_instance_profile {
    name = aws_iam_instance_profile.ssm_profile.name
  }
  user_data = filebase64("${path.module}/scripts/user_data.sh")
}

resource "aws_autoscaling_group" "asg_1_r2" {
  provider = aws.west1
  name                 = "ASG1-r2"
  desired_capacity     = 2
  max_size             = 4
  min_size             = 2
  health_check_type    = "EC2"
  termination_policies = ["OldestInstance"]
  vpc_zone_identifier  = [aws_subnet.private_e_az1_r2.id, aws_subnet.private_f_az2_r2.id]

  launch_template {
    id      = aws_launch_template.web_r2.id
    version = "$Latest"
  }

  lifecycle {
    ignore_changes = [desired_capacity]
  }
}

resource "aws_autoscaling_policy" "scale_out_r2" {
  provider = aws.west1
  name                   = "scale_out-r2"
  autoscaling_group_name = aws_autoscaling_group.asg_1_r2.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 10
}

resource "aws_cloudwatch_metric_alarm" "scale_out_r2" {
  provider = aws.west1
  alarm_name          = "scale_out-r2"
  alarm_description   = "CPU Utilization"
  alarm_actions       = [aws_autoscaling_policy.scale_out_r2.arn]
  comparison_operator = "GreaterThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  threshold           = "70"
  evaluation_periods  = "2"
  period              = "30"
  statistic           = "Average"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg_1_r2.name
  }
}

#ASG APP
resource "aws_launch_template" "app_r2" {
  provider = aws.west1
  name_prefix   = "app-r2"
  image_id      = var.amazon_linux_2023_uswest1
  instance_type = "t2.micro"
  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.app_r2.id]
  }
  iam_instance_profile {
    name = aws_iam_instance_profile.ssm_secrets_manager_profile.name
  }
  user_data = filebase64("${path.module}/scripts/user_data.sh")
}

resource "aws_autoscaling_group" "asg_2_r2" {
  provider = aws.west1
  name                 = "ASG2-r2"
  desired_capacity     = 2
  max_size             = 4
  min_size             = 2
  health_check_type    = "EC2"
  termination_policies = ["OldestInstance"]
  vpc_zone_identifier  = [aws_subnet.private_a_az1_r2.id, aws_subnet.private_b_az2_r2.id]

  launch_template {
    id      = aws_launch_template.app_r2.id
    version = "$Latest"
  }

  lifecycle {
    ignore_changes = [desired_capacity]
  }
}

resource "aws_autoscaling_policy" "asg2_scale_out_r2" {
  provider = aws.west1
  name                   = "asg2_scale_out_r2"
  autoscaling_group_name = aws_autoscaling_group.asg_2_r2.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 10
}

resource "aws_cloudwatch_metric_alarm" "asg2_scale_out_r2" {
  provider = aws.west1
  alarm_name          = "asg2_scale_out_r2"
  alarm_description   = "CPU Utilization"
  alarm_actions       = [aws_autoscaling_policy.asg2_scale_out_r2.arn]
  comparison_operator = "GreaterThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  threshold           = "60"
  evaluation_periods  = "3"
  period              = "30"
  statistic           = "Average"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg_2_r2.name
  }
}
