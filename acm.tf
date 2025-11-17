# ACM for ALB | Region 1
resource "aws_acm_certificate" "alb_cert" {
  domain_name       = var.domain
  validation_method = "DNS"
}

resource "aws_route53_record" "alb_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.alb_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  zone_id         = data.aws_route53_zone.victorponce.zone_id
  name            = each.value.name
  type            = each.value.type
  records         = [each.value.record]
  ttl             = 60
}

resource "aws_acm_certificate_validation" "alb_cert_validation" {
  certificate_arn         = aws_acm_certificate.alb_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.alb_cert_validation : record.fqdn]
}

# ACM for ALB | Region 2
provider "aws" {
  alias  = "west1"
  region = "us-west-1"
}

resource "aws_acm_certificate" "alb_cert_r2" {
  provider          = aws.west1
  domain_name       = var.domain
  validation_method = "DNS"
}

resource "aws_route53_record" "alb_cert_validation_r2" {
  #provider = aws.west1
  for_each = {
    for dvo in aws_acm_certificate.alb_cert_r2.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  zone_id         = data.aws_route53_zone.victorponce.zone_id
  name            = each.value.name
  type            = each.value.type
  records         = [each.value.record]
  ttl             = 60
}

resource "aws_acm_certificate_validation" "alb_cert_validation_r2" {
  provider                = aws.west1
  certificate_arn         = aws_acm_certificate.alb_cert_r2.arn
  validation_record_fqdns = [for record in aws_route53_record.alb_cert_validation_r2 : record.fqdn]
}

# ACM for CloudFront
provider "aws" {
  alias  = "use1"
  region = "us-east-1"
}

resource "aws_acm_certificate" "cf_cert" {
  provider          = aws.use1
  domain_name       = var.domain
  validation_method = "DNS"
}

resource "aws_route53_record" "cf_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cf_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  zone_id         = data.aws_route53_zone.victorponce.zone_id
  name            = each.value.name
  type            = each.value.type
  records         = [each.value.record]
  ttl             = 60
}

resource "aws_acm_certificate_validation" "cf_cert_validation" {
  provider                = aws.use1
  certificate_arn         = aws_acm_certificate.cf_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cf_cert_validation : record.fqdn]
}