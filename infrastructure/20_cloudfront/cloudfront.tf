locals {
  origin_id = "s3_oac"
  my_domain = "my-web-site.${data.aws_route53_zone.ippon.name}"
}

module "cdn" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "3.4.1"

  comment             = "My awesome CloudFront"
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  retain_on_delete    = false
  wait_for_deployment = true
  default_root_object = "index.html"

  create_origin_access_identity = true

  create_origin_access_control = true
  origin_access_control = {
    (local.origin_id) = {
      description      = "CloudFront access to S3"
      origin_type      = "s3"
      signing_behavior = "always"
      signing_protocol = "sigv4"
    }
  }

  origin = {
    (local.origin_id) = {
      domain_name           = module.s3_bucket.s3_bucket_bucket_domain_name
      origin_access_control = local.origin_id # key in `origin_access_control`
    }
  }

  default_cache_behavior = {
    target_origin_id       = local.origin_id
    viewer_protocol_policy = "redirect-to-https"
  }

  aliases = [
    local.my_domain
  ]

  viewer_certificate = {
    cloudfront_default_certificate = false
    acm_certificate_arn            = aws_acm_certificate.cert.arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
  }

  logging_config = {
    bucket = module.cloudfront_log_bucket.s3_bucket_bucket_domain_name
  }

  providers = {
    aws = aws.us
  }
}

data "aws_route53_zone" "ippon" {
  name = "sbx.aws.ippon.fr"
}

resource "aws_route53_record" "cloudfront" {
  zone_id = data.aws_route53_zone.ippon.zone_id
  name    = local.my_domain
  type    = "A"

  alias {
    name                   = module.cdn.cloudfront_distribution_domain_name
    zone_id                = module.cdn.cloudfront_distribution_hosted_zone_id
    evaluate_target_health = true
  }
}
