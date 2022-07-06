data "terraform_remote_state" "infrastructure" {
  backend = "s3"
  config = {
    bucket = "${var.project}-terraform-state"
    key    = "${var.environment}/infrastructure/terraform.tfstate"
    region = "us-east-2"
    profile  = var.profile
  }
}
data "aws_ssm_parameter" "s3_bucket" {
  name = "go-lambda-bucket"
}
resource "aws_s3_object" "object" {
  bucket =  data.aws_ssm_parameter.s3_bucket.value
  key    = "${var.s3_key}/${var.archive_name}"
  source = var.source_archive
  etag = var.archive_md5
}
resource "aws_cloudwatch_log_group" "function_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.lambda_function.id}"
  retention_in_days = 7
  lifecycle {
    prevent_destroy = false
  }
}
resource "aws_apigatewayv2_api" "lambda-gw" {
  count                      = var.enable_api_gw ? 1 : 0
  name                       = "lambda-gw"
  protocol_type              = "HTTP"
  target                     = "${aws_lambda_function.lambda_function.arn}"
}
resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.lambda-gw[0].execution_arn}/*/*"
}
resource "aws_dynamodb_table" "dynamodb-table" {
  count                      = var.enable_dynamo ? 1 : 0
  name           = var.enable_dynamo.name
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = var.enable_dynamo.hash_key

  attribute {
    name = var.enable_dynamo.attribute.name
    type = var.enable_dynamo.attribute.type
  }
}
resource "aws_lambda_function" "lambda_function" {
  depends_on = [aws_s3_object.object]
  handler = var.function_handler
  function_name = var.function_name
  role          = data.terraform_remote_state.infrastructure.outputs.lambda_role
  source_code_hash = var.archive_sha256
  s3_bucket = data.terraform_remote_state.infrastructure.outputs.bucket_name
  s3_key = "${var.s3_key}/${var.archive_name}"
  timeout = var.timeout
  runtime = var.runtime
}

