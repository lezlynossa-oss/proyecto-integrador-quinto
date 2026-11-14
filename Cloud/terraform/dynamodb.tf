# Tabla donde Lambda guarda cada predicción que se hace desde la web
resource "aws_dynamodb_table" "predicciones" {
  name         = "${var.proyecto}-predicciones"
  billing_mode = "PAY_PER_REQUEST" # pagas solo por lo que usas; sin uso = $0
  hash_key     = "id"              # clave primaria: un ID único por predicción

  attribute {
    name = "id"
    type = "S" # S = string (texto)
  }
}