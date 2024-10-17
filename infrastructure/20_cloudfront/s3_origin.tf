locals {
  origin_bucket_name = "twitch-live-17102024-my-web-site-origin"
}

module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = local.origin_bucket_name
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  # policy = data.aws_iam_policy_document.origin_bucket_policy.json
}


# data "aws_iam_policy_document" "origin_bucket_policy" {
#   statement {
#     effect = "Allow"
#     principals {
#
#     }
#   }
# }
