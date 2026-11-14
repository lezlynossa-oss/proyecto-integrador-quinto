# Variables: valores que reutilizamos en varios archivos.
# Si mañana queremos cambiar el prefijo, se cambia solo aquí.
variable "proyecto" {
  description = "Prefijo para el nombre de todos los recursos"
  type        = string
  default     = "asp"
}