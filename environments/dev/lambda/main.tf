provider "aws" {
  region = var.region
  profile= var.profile
}
#TODO - Currently shares state across environments.  Is this wanted?
terraform {
  backend "s3" {
    bucket         = "go-lambda-terraform-state"
    key            = "dev/infrastructure/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "dev-go-lambda-terraform-locks"
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

#TODO - Currently one bucket for all functions per enviroment. Wanted?
module "lambda_infrastructure" {
  source = "../../../modules/lambda-infrastructure"
  environment = var.environment
  region = var.region
  profile = var.profile
  s3_bucket = local.s3_env_bucket
  s3_asset_bucket = local.s3_env_asset_bucket
}