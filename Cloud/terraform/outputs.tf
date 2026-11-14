# Outputs: datos que Terraform te muestra al terminar
output "bucket_datos" {
  value = aws_s3_bucket.datos.bucket
}

output "bucket_web" {
  value = aws_s3_bucket.web.bucket
}

output "url_web" {
  value = "http://${aws_s3_bucket_website_configuration.web.website_endpoint}"
}
output "tabla_dynamodb" {
  value = aws_dynamodb_table.predicciones.name
}
output "lambda_nombre" {
  value = aws_lambda_function.prediccion.function_name
}
output "url_api" {
  value = "${aws_apigatewayv2_api.api.api_endpoint}/predict"
}