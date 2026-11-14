# Nombre de la función Lambda (lo usamos en varios archivos)
locals {
  nombre_lambda = "${var.proyecto}-prediccion"
}

# Grupo de logs donde Lambda escribirá cada ejecución
resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${local.nombre_lambda}"
  retention_in_days = 7 # borra logs viejos después de 7 días (ahorra costos)
}
