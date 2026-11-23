# =====================================================
# Archivos del modelo en el bucket privado (carpeta modelo/)
# Vienen de MachineLearning/modelos/, generados por los notebooks
# =====================================================
locals {
  carpeta_modelos = "${path.module}/../../MachineLearning/modelos"
}

# Perfiles de vulnerabilidad: escalado + PCA + centroides de K-Means
resource "aws_s3_object" "clustering" {
  bucket       = aws_s3_bucket.datos.id
  key          = "modelo/clustering_config.json"
  source       = "${local.carpeta_modelos}/clustering_config.json"
  content_type = "application/json"
  etag         = filemd5("${local.carpeta_modelos}/clustering_config.json") # si el archivo cambia, se vuelve a subir
}

# Riesgo de no afiliación: regresión logística + indicadores por localidad
resource "aws_s3_object" "modelo_afiliacion" {
  bucket       = aws_s3_bucket.datos.id
  key          = "modelo/modelo_afiliacion.json"
  source       = "${local.carpeta_modelos}/modelo_afiliacion.json"
  content_type = "application/json"
  etag         = filemd5("${local.carpeta_modelos}/modelo_afiliacion.json")
}