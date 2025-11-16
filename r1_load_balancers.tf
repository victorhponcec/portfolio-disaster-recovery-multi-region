#LB - Internet Facing
resource "aws_lb" "lba" {
  name               = "lba-internet"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lba.id]
  subnets            = [aws_subnet.public_a_az1.id, aws_subnet.public_b_az2.id]
}
resource "aws_lb_target_group" "tg_a" {
  name     = "tg-a"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_lb_listener" "lba_https" {
  load_balancer_arn = aws_lb.lba.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate_validation.alb_cert_validation.certificate_arn
  default_action {
    type = "forward"
    forward {
      target_group {
        arn    = aws_lb_target_group.tg_a.arn
        weight = 100
      }
    }
  }
}

resource "aws_autoscaling_attachment" "asg_lba" {
  autoscaling_group_name = aws_autoscaling_group.asg_1.id
  lb_target_group_arn    = aws_lb_target_group.tg_a.arn
}

#LB - Internal (APP)
resource "aws_lb" "lbb" {
  name               = "lbb-internal"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lbb.id]
  subnets            = [aws_subnet.private_a_az1.id, aws_subnet.private_b_az2.id]
}
resource "aws_lb_target_group" "tg_b" {
  name     = "tg-b"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}
resource "aws_lb_listener" "lbb_listner" {
  load_balancer_arn = aws_lb.lbb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "forward"
    forward {
      target_group {
        arn    = aws_lb_target_group.tg_b.arn
        weight = 100
      }
    }
  }
}
resource "aws_autoscaling_attachment" "asg_lbb" {
  autoscaling_group_name = aws_autoscaling_group.asg_2.id
  lb_target_group_arn    = aws_lb_target_group.tg_b.arn
}