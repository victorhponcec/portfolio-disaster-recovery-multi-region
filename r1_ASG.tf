#ASG WEB
resource "aws_launch_template" "web" {
  name_prefix   = "web"
  image_id      = var.amazon_linux_2023
  instance_type = "t2.micro"
  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.web.id]
  }
  iam_instance_profile {
    name = aws_iam_instance_profile.ssm_profile.name
  }
  user_data = filebase64("${path.module}/scripts/user_data.sh")
}

resource "aws_autoscaling_group" "asg_1" {
  name                 = "ASG1"
  desired_capacity     = 2
  max_size             = 4
  min_size             = 2
  health_check_type    = "EC2"
  termination_policies = ["OldestInstance"]
  vpc_zone_identifier  = [aws_subnet.private_e_az1.id, aws_subnet.private_f_az2.id]

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  lifecycle {
    ignore_changes = [desired_capacity]
  }
}

resource "aws_autoscaling_policy" "scale_out" {
  name                   = "scale_out"
  autoscaling_group_name = aws_autoscaling_group.asg_1.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 10
}

resource "aws_cloudwatch_metric_alarm" "scale_out" {
  alarm_name          = "scale_out"
  alarm_description   = "CPU Utilization"
  alarm_actions       = [aws_autoscaling_policy.scale_out.arn]
  comparison_operator = "GreaterThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  threshold           = "70"
  evaluation_periods  = "2"
  period              = "30"
  statistic           = "Average"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg_1.name
  }
}

#ASG APP
resource "aws_launch_template" "app" {
  name_prefix   = "app"
  image_id      = var.amazon_linux_2023
  instance_type = "t2.micro"
  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.app.id]
  }
  iam_instance_profile {
    name = aws_iam_instance_profile.ssm_secrets_manager_profile.name
  }
  user_data = filebase64("${path.module}/scripts/user_data.sh")
}

resource "aws_autoscaling_group" "asg_2" {
  name                 = "ASG2"
  desired_capacity     = 2
  max_size             = 4
  min_size             = 2
  health_check_type    = "EC2"
  termination_policies = ["OldestInstance"]
  vpc_zone_identifier  = [aws_subnet.private_a_az1.id, aws_subnet.private_b_az2.id]

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  lifecycle {
    ignore_changes = [desired_capacity]
  }
}

resource "aws_autoscaling_policy" "asg2_scale_out" {
  name                   = "asg2_scale_out"
  autoscaling_group_name = aws_autoscaling_group.asg_2.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 10
}

resource "aws_cloudwatch_metric_alarm" "asg2_scale_out" {
  alarm_name          = "asg2_scale_out"
  alarm_description   = "CPU Utilization"
  alarm_actions       = [aws_autoscaling_policy.asg2_scale_out.arn]
  comparison_operator = "GreaterThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  threshold           = "60"
  evaluation_periods  = "3"
  period              = "30"
  statistic           = "Average"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg_2.name
  }
}
