provider "aws" {
  region = var.region
  profile= var.profile
}
//TODO: MOVE PROJECT STATE UP TO TOP
# resource "aws_s3_bucket" "terraform_state" {
#   bucket = "${var.project}-terraform-state"
# }
# resource "aws_s3_bucket_acl" "bucket_acl" {
#   bucket = aws_s3_bucket.terraform_state.id
#   acl    = "private"
# }
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "${var.environment}-${var.project}-terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}