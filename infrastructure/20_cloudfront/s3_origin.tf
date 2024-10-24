locals {
  origin_bucket_name = "twitch-live-17102024-my-web-site-origin"
}

module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.2.1"

  bucket = local.origin_bucket_name

  control_object_ownership = true
  object_ownership         = "BucketOwnerEnforced"

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  attach_policy = true
  policy        = data.aws_iam_policy_document.origin_bucket_policy.json

  # For tests only
  force_destroy = true
}


data "aws_iam_policy_document" "origin_bucket_policy" {
  # Origin Access Controls
  statement {
    sid = "S3GetObjectsDistribution"
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "${module.s3_bucket.s3_bucket_arn}/*"
    ]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values = [
        module.cdn.cloudfront_distribution_arn
      ]
    }
  }
}
