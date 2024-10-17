locals {
  role_name = "twitch-live-17102024-my-web-site"
}

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = ["d89e3bd43d5d909b47a18977aa9d5ce36cee184c"]
}

resource "aws_iam_role" "twitch_live" {
  name               = local.role_name
  description        = "Role dedicated to deploy infrastructure during the Twitch Live on October 17th 2024 with Arnaud and Timothee"
  assume_role_policy = data.aws_iam_policy_document.twitch_live_assume_role.json
}

data "aws_iam_policy_document" "twitch_live_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type = "Federated"
      identifiers = [
        aws_iam_openid_connect_provider.github.arn
      ]
    }
    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values = [
        "sts.amazonaws.com"
      ]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:ippontech/my-web-site:*"
      ]
    }
  }
}

resource "aws_iam_role_policy_attachment" "cloudfront" {
  role       = aws_iam_role.twitch_live.name
  policy_arn = "arn:aws:iam::aws:policy/CloudFrontFullAccess"
}

resource "aws_iam_role_policy" "twitch_live_runner" {
  name   = "${local.role_name}-runner"
  role   = aws_iam_role.twitch_live.id
  policy = data.aws_iam_policy_document.twitch_live_runner.json
}

data "aws_iam_policy_document" "twitch_live_runner" {
  statement {
    effect = "Allow"
    actions = [
      "s3:*"
    ]
    resources = [
      "arn:aws:s3:::twitch-live-17102024-*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:*"
    ]
    resources = [
      "arn:aws:dynamodb:${var.region}:${data.aws_caller_identity.current.account_id}:table/twitch-live-17102024-tf-states-lock"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "iam:*OpenID*"
    ]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "iam:*"
    ]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/twitch-live-17102024-my-web-site"
    ]
  }
}
