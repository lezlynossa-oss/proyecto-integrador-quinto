# =====================================================
# ROL de Lambda: la "identidad" que la función asume
# =====================================================
resource "aws_iam_role" "lambda" {
  name = "${var.proyecto}-lambda-rol"

  # ¿Quién puede usar este rol? Solo el servicio Lambda
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

# =====================================================
# PERMISOS del rol (MÍNIMO PRIVILEGIO)
# =====================================================
resource "aws_iam_role_policy" "lambda" {
  name = "${var.proyecto}-lambda-permisos"
  role = aws_iam_role.lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # Solo LEER, y solo los archivos dentro de la carpeta modelo/
        Sid      = "LeerModelo"
        Effect   = "Allow"
        Action   = ["s3:GetObject"]
        Resource = "${aws_s3_bucket.datos.arn}/modelo/*"
      },
      {
        # Solo AGREGAR registros, y solo en nuestra tabla
        Sid      = "GuardarPredicciones"
        Effect   = "Allow"
        Action   = ["dynamodb:PutItem"]
        Resource = aws_dynamodb_table.predicciones.arn
      },
      {
        # Solo escribir logs, y solo en su propio grupo de logs
        Sid      = "EscribirLogs"
        Effect   = "Allow"
        Action   = ["logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "${aws_cloudwatch_log_group.lambda.arn}:*"
      }
    ]
  })
}
