data "aws_caller_identity" "current" {}
#TODO - currently env_regions deploys into a region based on the environment defined from the consumer
#of the module.  It only works in one account.  Wanted?
locals {
  account_id = data.aws_caller_identity.current.account_id
  deployed_region = "${var.env_regions["${var.environment}"]}"
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = var.s3_bucket
}
resource "aws_ssm_parameter" "bucket_param" {
  name  = "go-lambda-bucket"
  type  = "String"
  value = aws_s3_bucket.lambda_bucket.id
}
resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.lambda_bucket.id
  acl    = "private"
}
resource "aws_s3_bucket" "lambda_asset_bucket" {
  bucket = var.s3_asset_bucket
}
resource "aws_s3_bucket_acl" "asset_bucket_acl" {
  bucket = aws_s3_bucket.lambda_asset_bucket.id
  acl    = "private"
}
resource "aws_iam_user" "lambda-developer" {
  name = "lambda-${var.environment}-developer"
  path = "/"
}

resource "aws_iam_group" "lambda-developers" {
  name = "lambda-${var.environment}-developers"
  path = "/"
}
resource "aws_iam_access_key" "lambda-developers-key" {
  user = aws_iam_user.lambda-developer.name
}
resource "aws_iam_group_membership" "lambda-developers-add" {
  name = "lambda-${var.environment}-developers"

  users = [
    aws_iam_user.lambda-developer.name
  ]

  group = aws_iam_group.lambda-developers.name
}
resource "aws_iam_group_policy_attachment" "lambda-developer-attach" {
  group      = aws_iam_group.lambda-developers.name
  policy_arn = aws_iam_policy.Lambda-developer-rights.arn
}

resource "aws_iam_policy" "Lambda-developer-rights" {
  name   = "Lambda${var.environment}Access"
  policy = data.aws_iam_policy_document.lambda_developer_policy_document.json
}
#TODO - Disallow destroy on buckets
#TODO - let describeparameters
data "aws_iam_policy_document" "lambda_developer_policy_document" {
  statement {
    sid = "PermissionToCreateFunction"
    actions = [
      "lambda:*"
    ]
    resources = ["arn:aws:lambda:${var.env_regions["${var.environment}"]}:*:function:*"]
  }
  statement {
    actions = [
    "ssm:DescribeParameters"
    ]
    resources = ["*"]
  }
   statement {
    actions = [
    "ssm:GetParameter"
    ]
    resources = ["arn:aws:ssm:${var.env_regions["${var.environment}"]}:${local.account_id}:parameter/*"]
  }
  statement {
    actions = [
    "iam:ListAccessKeys"
    ]
    resources = [
      "arn:aws:iam::${local.account_id}:user/lambda-developer"
    ]
  }

  statement {
    sid ="PassRole"
    actions = [
      "iam:PassRole",
      "iam:GetRole"
    ]
    resources = [aws_iam_role.lambda_iam_role.arn]
  }
   statement {
    actions = [
    "iam:ListAttachedRolePolicies"
    ]
    resources = [
      aws_iam_role.lambda_iam_role.arn
    ]
  }
  statement {
    actions = [
    "iam:ListAccessKeys",
    "iam:GetUser"
    ]
    resources = [
      aws_iam_user.lambda-developer.arn
    ]
  }
   statement {
    actions = [
    "iam:GetPolicy",
      "iam:GetPolicyVersion"
    ]
    resources = [
      aws_iam_policy.lambda_lambda_execution.arn,
      "arn:aws:iam::${local.account_id}:policy/LambdaAccess"
    ]
  }
  statement {
    actions = [
      "s3:*"
    ]

    resources = [
      "arn:aws:s3:::${var.s3_bucket}",
      "arn:aws:s3:::${var.s3_bucket}/*",
      "arn:aws:s3:::${var.s3_asset_bucket}",
      "arn:aws:s3:::${var.s3_asset_bucket}/*"
    ]
  }
  statement {
    actions = [
    "iam:GetGroup",
      "iam:ListAttachedGroupPolicies"
    ]
    resources = [
      aws_iam_group.lambda-developers.arn
    ]
  }
}

resource "aws_iam_role" "lambda_iam_role" {
  name = "lambda_${var.environment}_iam_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role = aws_iam_role.lambda_iam_role.name
  policy_arn = aws_iam_policy.lambda_lambda_execution.arn
}
resource "aws_iam_policy" "lambda_lambda_execution" {
  name = "lambda_${var.environment}_execution"
  policy = data.aws_iam_policy_document.lambda_policy_data.json
}
#TODO - Make asset bucket optional
data "aws_iam_policy_document" "lambda_policy_data" {
  statement {
    actions = [
      "s3:ListAllMyBuckets",
      "s3:GetBucketLocation"
    ]

    resources = [
      "arn:aws:s3:::*",
    ]
  }
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]

    resources = [
      "arn:aws:s3:::${var.s3_bucket}",
      "arn:aws:s3:::${var.s3_bucket}/*",
      "arn:aws:s3:::${var.s3_asset_bucket}",
      "arn:aws:s3:::${var.s3_asset_bucket}/*"
    ]
  }
}


