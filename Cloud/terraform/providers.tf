# ¿Qué versión de Terraform y qué "plugins" (providers) necesita este proyecto?
terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
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