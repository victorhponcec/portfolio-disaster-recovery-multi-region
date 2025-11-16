data "aws_route53_zone" "victorponce" {
  name         = var.domain
  private_zone = false
}

resource "aws_route53_record" "lb" {
  zone_id = data.aws_route53_zone.victorponce.zone_id
  name    = var.domain
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.cf_dist.domain_name
    zone_id                = aws_cloudfront_distribution.cf_dist.hosted_zone_id
    evaluate_target_health = false
  }
}