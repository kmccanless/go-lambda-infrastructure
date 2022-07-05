provider "aws" {
  region = var.region
  profile= var.profile
}
terraform {
  backend "s3" {
    bucket         = "go-lambda-terraform-state"
    key            = "production/infrastructure/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "production-go-lambda-terraform-locks"
    encrypt        = true
    profile        = "keith"
  }
}

locals {
  s3_env_bucket = "${var.environment}-${var.s3_bucket}"
  s3_env_asset_bucket = "${var.environment}-${var.s3_asset_bucket}"
}
resource "random_id" "bucket" {
  byte_length = 5
}
module "lambda_infrastructure" {
  source = "../../../modules/lambda-infrastructure"
  environment = var.environment
  region = var.region
  profile = var.profile
  s3_bucket = local.s3_env_bucket
  s3_asset_bucket = local.s3_env_asset_bucket
}