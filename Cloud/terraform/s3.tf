# Consulta a AWS: "¿quién soy?" → nos da el número de cuenta
data "aws_caller_identity" "actual" {}

locals {
  sufijo = data.aws_caller_identity.actual.account_id
}

# =====================================================
# BUCKET 1: Datos y modelo (PRIVADO + VERSIONADO)
# =====================================================
resource "aws_s3_bucket" "datos" {
  bucket        = "${var.proyecto}-datos-modelo-${local.sufijo}"
  force_destroy = true # permite borrarlo aunque tenga archivos (útil en un proyecto académico)
}

# Versionado: guarda versiones anteriores de cada archivo (recuperación ante desastres)
resource "aws_s3_bucket_versioning" "datos" {
  bucket = aws_s3_bucket.datos.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Bloquea TODO acceso público al bucket de datos
resource "aws_s3_bucket_public_access_block" "datos" {
  bucket                  = aws_s3_bucket.datos.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# =====================================================
# BUCKET 2: Sitio web estático (PÚBLICO, solo lectura)
# =====================================================
resource "aws_s3_bucket" "web" {
  bucket        = "${var.proyecto}-web-${local.sufijo}"
  force_destroy = true
}

# Lo convierte en sitio web: al entrar, muestra index.html
resource "aws_s3_bucket_website_configuration" "web" {
  bucket = aws_s3_bucket.web.id
  index_document {
    suffix = "index.html"
  }
}

# Permite que una "política" lo haga público (por defecto AWS lo bloquea)
resource "aws_s3_bucket_public_access_block" "web" {
  bucket                  = aws_s3_bucket.web.id
  block_public_acls       = true
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = false
}

# Política: cualquiera puede LEER (GetObject) los archivos de la web, pero nadie puede escribir
resource "aws_s3_bucket_policy" "web" {
  bucket = aws_s3_bucket.web.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "LecturaPublica"
      Effect    = "Allow"
      Principal = "*"
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.web.arn}/*"
    }]
  })

  # Primero se desbloquea el acceso público, luego se pone la política
  depends_on = [aws_s3_bucket_public_access_block.web]
}