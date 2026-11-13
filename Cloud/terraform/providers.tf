# ¿Qué versión de Terraform y qué "plugins" (providers) necesita este proyecto?
terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws" # el plugin oficial de AWS
      version = "~> 6.0"        # cualquier versión 6.x (evita cambios incompatibles)
    }
  }
}

# ¿Con qué cuenta y en qué región trabajamos?
provider "aws" {
  region  = "us-east-1" # N. Virginia, la región que elegimos
  profile = "lez"       # usa TU cuenta (las credenciales del perfil "lez")

  # Etiquetas que se ponen automáticamente a TODOS los recursos
  default_tags {
    tags = {
      Project   = "ASP"       # para filtrar los costos en Cost Explorer
      ManagedBy = "Terraform" # para saber que esto no se creó a mano
    }
  }
}