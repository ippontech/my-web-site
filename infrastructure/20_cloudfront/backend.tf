# Note: at the moment, it's not possible to use variables in Terraform backend
terraform {
  backend "s3" {
    bucket         = "twitch-live-17102024-tf-states"
    key            = "20_cloudfront/terraform.tfstate"
    region         = "eu-west-3"
    dynamodb_table = "twitch-live-17102024-tf-states-lock"
    encrypt        = true
  }
}
