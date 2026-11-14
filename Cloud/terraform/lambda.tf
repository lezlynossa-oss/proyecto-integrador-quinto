# Empaqueta la carpeta Cloud/lambda en un .zip automáticamente
data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda"
  output_path = "${path.module}/build/lambda.zip"
}

resource "aws_lambda_function" "prediccion" {
  function_name = local.nombre_lambda     # "asp-prediccion"
  role          = aws_iam_role.lambda.arn # el rol del bloque anterior
  runtime       = "python3.12"
  handler       = "handler.lambda_handler" # archivo.función
  architectures = ["arm64"]                # procesador Graviton: ~20% más barato

  filename         = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256 # detecta cambios en el código

  memory_size = 256 # MB
  timeout     = 10  # segundos máximos por ejecución

  # Variables de entorno: el código lee los nombres de aquí, no están "quemados"
  environment {
    variables = {
      TABLA_PREDICCIONES = aws_dynamodb_table.predicciones.name
      BUCKET_MODELO      = aws_s3_bucket.datos.bucket
    }
  }

  depends_on = [aws_cloudwatch_log_group.lambda, aws_iam_role_policy.lambda]
}
