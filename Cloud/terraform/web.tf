# Sube index.html al bucket web, rellenando la URL de la API
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.web.id
  key          = "index.html"
  content_type = "text/html; charset=utf-8"

  content = templatefile("${path.module}/../web/index.html.tpl", {
    url_api = "${aws_apigatewayv2_api.api.api_endpoint}/predict"
  })
}
# Sube los datos agregados del dashboard (se generan con Mineria/EDA/03_dashboard_eda.ipynb)
resource "aws_s3_object" "dashboard" {
  bucket       = aws_s3_bucket.web.id
  key          = "dashboard.json"
  source       = "${path.module}/../web/dashboard.json"
  etag         = filemd5("${path.module}/../web/dashboard.json")
  content_type = "application/json; charset=utf-8"
}
