locals {
  origin_id = "myOriginId"
}

module "cdn" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "3.4.1"

  # aliases = ["cdn.example.com"]

  comment             = "My awesome CloudFront"
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  retain_on_delete    = false
  wait_for_deployment = true

  create_origin_access_identity = true

  origin_access_control = {
    s3_oac = {
      description      = "CloudFront access to S3"
      origin_type      = "s3"
      signing_behavior = "always"
      signing_protocol = "sigv4"
    }
  }

  origin = {
    s3_one = {
      domain_name           = module.s3_bucket.s3_bucket_bucket_domain_name
      origin_access_control = "s3_oac" # key in `origin_access_control`
      origin_id             = local.origin_id
    }
  }

  default_cache_behavior = {
    target_origin_id       = local.origin_id
    viewer_protocol_policy = "allow-all"
  }

  #   viewer_certificate = {
  #     acm_certificate_arn = "arn:aws:acm:us-east-1:135367859851:certificate/1032b155-22da-4ae0-9f69-e206f825458b"
  #     ssl_support_method  = "sni-only"
  #   }
}
