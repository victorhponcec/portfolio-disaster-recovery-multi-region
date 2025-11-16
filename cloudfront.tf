resource "aws_cloudfront_distribution" "cf_dist" {
  enabled             = true
  default_root_object = "index.html"
  web_acl_id          = aws_wafv2_web_acl.cf_waf.arn

  origin {
    domain_name = aws_lb.lba.dns_name
    origin_id   = "alb-origin"

    custom_origin_config {
      origin_protocol_policy = "https-only"
      https_port             = 443
      http_port              = 80
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "alb-origin"

    forwarded_values {
      query_string = true
      headers      = ["*"]
      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["CL", "US"]
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate_validation.cf_cert_validation.certificate_arn
    ssl_support_method  = "sni-only"
  }

  aliases = ["victorponce.site"]
}
