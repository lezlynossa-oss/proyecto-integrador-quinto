# Sube index.html al bucket web, rellenando la URL de la API
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.web.id
  key          = "index.html"
  content_type = "text/html; charset=utf-8"

  content = templatefile("${path.module}/../web/index.html.tpl", {
    url_api = "${aws_apigatewayv2_api.api.api_endpoint}/predict"
  })
}