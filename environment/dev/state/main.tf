provider "aws" {
  region = var.region
  profile= var.profile
}
resource "aws_s3_bucket" "terraform_state" {
  bucket = "${var.project}-terraform-state"
  #should enable versioning for real-world use
  versioning {
    enabled = false
  }
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