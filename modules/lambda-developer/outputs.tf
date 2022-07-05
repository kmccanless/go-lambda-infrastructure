output "lambda_name" {
  value = aws_lambda_function.lambda_function.function_name
}
output "lambda_arn" {
  value = aws_lambda_function.lambda_function.arn
}
output "api_gateway_endpoint" {
   value = aws_apigatewayv2_api.lambda-gw[count.index].api_endpoint
}