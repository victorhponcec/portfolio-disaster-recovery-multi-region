#SG web_r2 
resource "aws_security_group" "web_r2" {
  name        = "web-r2"
  description = "allow lb/app traffic"
  vpc_id      = aws_vpc.secondary.id
}
#public ALB
resource "aws_vpc_security_group_ingress_rule" "web_allow_443_r2" {
  security_group_id            = aws_security_group.web_r2.id
  referenced_security_group_id = aws_security_group.lba_r2.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}
resource "aws_vpc_security_group_ingress_rule" "web_allow_80_r2" {
  security_group_id            = aws_security_group.web_r2.id
  referenced_security_group_id = aws_security_group.lba_r2.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
}
#app
resource "aws_vpc_security_group_ingress_rule" "web_app_allow_443_r2" {
  security_group_id            = aws_security_group.web_r2.id
  referenced_security_group_id = aws_security_group.app_r2.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}
#break glass
resource "aws_vpc_security_group_ingress_rule" "web_bg_allow_22_r2" {
  security_group_id            = aws_security_group.web_r2.id
  referenced_security_group_id = aws_security_group.break_glass_r2.id
  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
}
resource "aws_vpc_security_group_egress_rule" "web_r2_egress_all_r2" {
  security_group_id = aws_security_group.web_r2.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

#SG LBA
resource "aws_security_group" "lba_r2" {
  name        = "lba_web_r2"
  description = "allow web_r2 traffic"
  vpc_id      = aws_vpc.secondary.id
}
resource "aws_vpc_security_group_ingress_rule" "lba_allow_443_r2" {
  security_group_id = aws_security_group.lba_r2.id
  prefix_list_id    = data.aws_ec2_managed_prefix_list.cloudfront_r2.id
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}
data "aws_ec2_managed_prefix_list" "cloudfront_r2" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}

resource "aws_vpc_security_group_egress_rule" "lba_egress_all_r2" {
  security_group_id = aws_security_group.lba_r2.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

#SG APP 
resource "aws_security_group" "app_r2" {
  name        = "app-r2"
  description = "allow web_r2/DB traffic"
  vpc_id      = aws_vpc.secondary.id
}
resource "aws_vpc_security_group_ingress_rule" "app_allow_443_r2" {
  security_group_id            = aws_security_group.app_r2.id
  referenced_security_group_id = aws_security_group.web_r2.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}
resource "aws_vpc_security_group_ingress_rule" "app_allow_80_r2" {
  security_group_id            = aws_security_group.app_r2.id
  referenced_security_group_id = aws_security_group.web_r2.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
}
#break glass
resource "aws_vpc_security_group_ingress_rule" "app_bg_allow_22_r2" {
  security_group_id            = aws_security_group.app_r2.id
  referenced_security_group_id = aws_security_group.break_glass_r2.id
  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
}
resource "aws_vpc_security_group_egress_rule" "app_egress_all_r2" {
  security_group_id = aws_security_group.app_r2.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

#SG LBB
resource "aws_security_group" "lbb_r2" {
  name        = "lbb_web_r2"
  description = "allow web_r2 tier traffic"
  vpc_id      = aws_vpc.secondary.id
}
resource "aws_vpc_security_group_ingress_rule" "lbb_allow_443_r2" {
  security_group_id            = aws_security_group.lbb_r2.id
  referenced_security_group_id = aws_security_group.web_r2.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}
resource "aws_vpc_security_group_ingress_rule" "lbb_allow_80_r2" {
  security_group_id            = aws_security_group.lbb_r2.id
  referenced_security_group_id = aws_security_group.web_r2.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
}
resource "aws_vpc_security_group_egress_rule" "lbb_egress_all_r2" {
  security_group_id = aws_security_group.lbb_r2.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

#SG DB 
resource "aws_security_group" "db_r2" {
  name        = "db-r2"
  description = "allow app traffic"
  vpc_id      = aws_vpc.secondary.id
}
resource "aws_vpc_security_group_ingress_rule" "db_allow_3306_r2" {
  security_group_id            = aws_security_group.db_r2.id
  referenced_security_group_id = aws_security_group.app_r2.id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
}
#break glass
resource "aws_vpc_security_group_ingress_rule" "db_bg_allow_3306_r2" {
  security_group_id            = aws_security_group.db_r2.id
  referenced_security_group_id = aws_security_group.break_glass_r2.id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
}

#SG SSM Endpoint (allow app/web_r2 tier)
resource "aws_security_group" "ssm_r2" {
  name        = "ssm-r2"
  description = "allow app traffic to ssm"
  vpc_id      = aws_vpc.secondary.id
}
resource "aws_vpc_security_group_ingress_rule" "ssm_app_allow_443_r2" {
  security_group_id            = aws_security_group.ssm_r2.id
  referenced_security_group_id = aws_security_group.app_r2.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}
resource "aws_vpc_security_group_ingress_rule" "ssm_web_r2_allow_443_r2" {
  security_group_id            = aws_security_group.ssm_r2.id
  referenced_security_group_id = aws_security_group.web_r2.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}
#break glass
resource "aws_vpc_security_group_ingress_rule" "ssm_bg_allow_443_r2" {
  security_group_id            = aws_security_group.ssm_r2.id
  referenced_security_group_id = aws_security_group.break_glass_r2.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}
resource "aws_vpc_security_group_egress_rule" "ssm_egress_all_r2" {
  security_group_id = aws_security_group.ssm_r2.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

#SG Secrets Manager Endpoint (allow app tier)
resource "aws_security_group" "secrets_manager_r2" {
  name        = "secrets_manager-r2"
  description = "allow app traffic to secrets_manager"
  vpc_id      = aws_vpc.secondary.id
}
resource "aws_vpc_security_group_ingress_rule" "secrets_manager_app_allow_443_r2" {
  security_group_id            = aws_security_group.secrets_manager_r2.id
  referenced_security_group_id = aws_security_group.app_r2.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}
#break glass
resource "aws_vpc_security_group_ingress_rule" "secrets_manager_bg_allow_443_r2" {
  security_group_id            = aws_security_group.secrets_manager_r2.id
  referenced_security_group_id = aws_security_group.break_glass_r2.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}
resource "aws_vpc_security_group_egress_rule" "secrets_manager_egress_all_r2" {
  security_group_id = aws_security_group.secrets_manager_r2.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

#SG Break Glass
resource "aws_security_group" "break_glass_r2" {
  name        = "ssh-r2"
  description = "allow SSH break glass server"
  vpc_id      = aws_vpc.secondary.id
}
resource "aws_vpc_security_group_ingress_rule" "break_glass_allow_ssh_r2" {
  security_group_id = aws_security_group.break_glass_r2.id
  cidr_ipv4         = var.on-prem-vpn
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}
resource "aws_vpc_security_group_egress_rule" "break_glass_egress_ssh_all_r2" {
  security_group_id = aws_security_group.break_glass_r2.id
  cidr_ipv4         = var.on-prem-vpn
  ip_protocol       = "-1"
}
