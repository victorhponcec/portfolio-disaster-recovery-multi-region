#SG WEB 
resource "aws_security_group" "web" {
  name        = "web"
  description = "allow lb/app traffic"
  vpc_id      = aws_vpc.main.id
}
#public ALB
resource "aws_vpc_security_group_ingress_rule" "web_allow_443" {
  security_group_id            = aws_security_group.web.id
  referenced_security_group_id = aws_security_group.lba.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}
resource "aws_vpc_security_group_ingress_rule" "web_allow_80" {
  security_group_id            = aws_security_group.web.id
  referenced_security_group_id = aws_security_group.lba.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
}
#app
resource "aws_vpc_security_group_ingress_rule" "web_app_allow_443" {
  security_group_id            = aws_security_group.web.id
  referenced_security_group_id = aws_security_group.app.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}
#break glass
resource "aws_vpc_security_group_ingress_rule" "web_bg_allow_22" {
  security_group_id            = aws_security_group.web.id
  referenced_security_group_id = aws_security_group.break_glass.id
  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
}
resource "aws_vpc_security_group_egress_rule" "web_egress_all" {
  security_group_id = aws_security_group.web.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

#SG LBA
resource "aws_security_group" "lba" {
  name        = "lba_web"
  description = "allow web traffic"
  vpc_id      = aws_vpc.main.id
}
resource "aws_vpc_security_group_ingress_rule" "lba_allow_443" {
  security_group_id = aws_security_group.lba.id
  prefix_list_id    = data.aws_ec2_managed_prefix_list.cloudfront.id
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}
data "aws_ec2_managed_prefix_list" "cloudfront" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}

resource "aws_vpc_security_group_egress_rule" "lba_egress_all" {
  security_group_id = aws_security_group.lba.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

#SG APP 
resource "aws_security_group" "app" {
  name        = "app"
  description = "allow web/DB traffic"
  vpc_id      = aws_vpc.main.id
}
resource "aws_vpc_security_group_ingress_rule" "app_allow_443" {
  security_group_id            = aws_security_group.app.id
  referenced_security_group_id = aws_security_group.web.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}
resource "aws_vpc_security_group_ingress_rule" "app_allow_80" {
  security_group_id            = aws_security_group.app.id
  referenced_security_group_id = aws_security_group.web.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
}
#break glass
resource "aws_vpc_security_group_ingress_rule" "app_bg_allow_22" {
  security_group_id            = aws_security_group.app.id
  referenced_security_group_id = aws_security_group.break_glass.id
  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
}
resource "aws_vpc_security_group_egress_rule" "app_egress_all" {
  security_group_id = aws_security_group.app.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

#SG LBB
resource "aws_security_group" "lbb" {
  name        = "lbb_web"
  description = "allow web tier traffic"
  vpc_id      = aws_vpc.main.id
}
resource "aws_vpc_security_group_ingress_rule" "lbb_allow_443" {
  security_group_id            = aws_security_group.lbb.id
  referenced_security_group_id = aws_security_group.web.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}
resource "aws_vpc_security_group_ingress_rule" "lbb_allow_80" {
  security_group_id            = aws_security_group.lbb.id
  referenced_security_group_id = aws_security_group.web.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
}
resource "aws_vpc_security_group_egress_rule" "lbb_egress_all" {
  security_group_id = aws_security_group.lbb.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

#SG DB 
resource "aws_security_group" "db" {
  name        = "db"
  description = "allow app traffic"
  vpc_id      = aws_vpc.main.id
}
resource "aws_vpc_security_group_ingress_rule" "db_allow_3306" {
  security_group_id            = aws_security_group.db.id
  referenced_security_group_id = aws_security_group.app.id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
}
#break glass
resource "aws_vpc_security_group_ingress_rule" "db_bg_allow_3306" {
  security_group_id            = aws_security_group.db.id
  referenced_security_group_id = aws_security_group.break_glass.id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
}

#SG SSM Endpoint (allow app/web tier)
resource "aws_security_group" "ssm" {
  name        = "ssm"
  description = "allow app traffic to ssm"
  vpc_id      = aws_vpc.main.id
}
resource "aws_vpc_security_group_ingress_rule" "ssm_app_allow_443" {
  security_group_id            = aws_security_group.ssm.id
  referenced_security_group_id = aws_security_group.app.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}
resource "aws_vpc_security_group_ingress_rule" "ssm_web_allow_443" {
  security_group_id            = aws_security_group.ssm.id
  referenced_security_group_id = aws_security_group.web.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}
#break glass
resource "aws_vpc_security_group_ingress_rule" "ssm_bg_allow_443" {
  security_group_id            = aws_security_group.ssm.id
  referenced_security_group_id = aws_security_group.break_glass.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}
resource "aws_vpc_security_group_egress_rule" "ssm_egress_all" {
  security_group_id = aws_security_group.ssm.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

#SG Secrets Manager Endpoint (allow app tier)
resource "aws_security_group" "secrets_manager" {
  name        = "secrets_manager"
  description = "allow app traffic to secrets_manager"
  vpc_id      = aws_vpc.main.id
}
resource "aws_vpc_security_group_ingress_rule" "secrets_manager_app_allow_443" {
  security_group_id            = aws_security_group.secrets_manager.id
  referenced_security_group_id = aws_security_group.app.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}
#break glass
resource "aws_vpc_security_group_ingress_rule" "secrets_manager_bg_allow_443" {
  security_group_id            = aws_security_group.secrets_manager.id
  referenced_security_group_id = aws_security_group.break_glass.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}
resource "aws_vpc_security_group_egress_rule" "secrets_manager_egress_all" {
  security_group_id = aws_security_group.secrets_manager.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

#SG Break Glass
resource "aws_security_group" "break_glass" {
  name        = "ssh"
  description = "allow SSH break glass server"
  vpc_id      = aws_vpc.main.id
}
resource "aws_vpc_security_group_ingress_rule" "break_glass_allow_ssh" {
  security_group_id = aws_security_group.break_glass.id
  cidr_ipv4         = var.on-prem-vpn
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}
resource "aws_vpc_security_group_egress_rule" "break_glass_egress_ssh_all" {
  security_group_id = aws_security_group.break_glass.id
  cidr_ipv4         = var.on-prem-vpn
  ip_protocol       = "-1"
}