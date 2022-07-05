provider "aws" {
  region = var.region
  profile= var.profile
}
terraform {
  backend "s3" {
    bucket         = "go-lambda-terraform-state"
    key            = "production/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "go-lambda-terraform-locks"
    encrypt        = true
    profile        = "keith"
  }
}
resource "aws_s3_bucket" "terraform_state" {
  bucket = "${var.project}-terraform-state"
  # Enable versioning so we can see the full revision history of our
  # state files
  versioning {
    enabled = true
  }
  # Enable server-side encryption by default
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "${var.project}-terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}
locals {
  s3_env_bucket = "${random_id.bucket.hex}-${var.s3_bucket}"
  s3_env_asset_bucket = "${random_id.bucket.hex}-${var.s3_asset_bucket}"
}
resource "random_id" "bucket" {
  byte_length = 5
}
module "lambda_infrastructure" {
  source = "../../modules"
  environment = var.environment
  region = var.region
  profile = var.profile
  s3_bucket = local.s3_env_bucket
  s3_asset_bucket = local.s3_env_asset_bucket
}