#LB - Internet Facing
resource "aws_lb" "lba_r2" {
  provider = aws.west1
  name               = "lba-internet-r2"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lba_r2.id]
  subnets            = [aws_subnet.public_a_az1_r2.id, aws_subnet.public_b_az2_r2.id]
}
resource "aws_lb_target_group" "tg_a_r2" {
  provider = aws.west1
  name     = "tg-a-r2"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.secondary.id
}

resource "aws_lb_listener" "lba_https_r2" {
  provider = aws.west1
  load_balancer_arn = aws_lb.lba_r2.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate_validation.alb_cert_validation_r2.certificate_arn
  default_action {
    type = "forward"
    forward {
      target_group {
        arn    = aws_lb_target_group.tg_a_r2.arn
        weight = 100
      }
    }
  }
}

resource "aws_autoscaling_attachment" "asg_lba_r2" {
  provider = aws.west1
  autoscaling_group_name = aws_autoscaling_group.asg_1_r2.id
  lb_target_group_arn    = aws_lb_target_group.tg_a_r2.arn
}

#LB - Internal (APP)
resource "aws_lb" "lbb_r2" {
  provider = aws.west1
  name               = "lbb-internal-r2"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lbb_r2.id]
  subnets            = [aws_subnet.private_a_az1_r2.id, aws_subnet.private_b_az2_r2.id]
}
resource "aws_lb_target_group" "tg_b_r2" {
  provider = aws.west1
  name     = "tg-b-r2"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.secondary.id
}
resource "aws_lb_listener" "lbb_listner_r2" {
  provider = aws.west1
  load_balancer_arn = aws_lb.lbb_r2.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "forward"
    forward {
      target_group {
        arn    = aws_lb_target_group.tg_b_r2.arn
        weight = 100
      }
    }
  }
}
resource "aws_autoscaling_attachment" "asg_lbb_r2" {
  provider = aws.west1
  autoscaling_group_name = aws_autoscaling_group.asg_2_r2.id
  lb_target_group_arn    = aws_lb_target_group.tg_b_r2.arn
}