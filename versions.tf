terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.25.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.32.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.15.0"
    }
  }

  required_version = ">= 0.14"
}

