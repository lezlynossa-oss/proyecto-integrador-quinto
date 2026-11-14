# =====================================================
# La API (tipo HTTP API: más simple y ~70% más barata que REST API)
# =====================================================
resource "aws_apigatewayv2_api" "api" {
  name          = "${var.proyecto}-api"
  protocol_type = "HTTP"

  # CORS: SOLO la página web de nuestro bucket puede llamar esta API desde un navegador
  cors_configuration {
    allow_origins = ["http://${aws_s3_bucket_website_configuration.web.website_endpoint}"]
    allow_methods = ["POST", "OPTIONS"]
    allow_headers = ["content-type"]
    max_age       = 300
  }
}

# Conexión API → Lambda (la API le pasa la petición completa a Lambda)
resource "aws_apigatewayv2_integration" "lambda" {
  api_id                 = aws_apigatewayv2_api.api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.prediccion.invoke_arn
  payload_format_version = "2.0"
}

# Ruta: cuando llegue un POST a /predict, mándalo a la integración con Lambda
resource "aws_apigatewayv2_route" "predict" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "POST /predict"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

# Etapa (stage): publica la API automáticamente con cada cambio
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = "$default"
  auto_deploy = true

  # Límite de peticiones: protege contra abuso y costos inesperados
  default_route_settings {
    throttling_rate_limit  = 10 # máx. 10 peticiones por segundo
    throttling_burst_limit = 20 # picos de hasta 20
  }
}

# Permiso: Lambda acepta ser invocada por ESTA API (y solo por ella)
resource "aws_lambda_permission" "apigw" {
  statement_id  = "PermitirAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.prediccion.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}
