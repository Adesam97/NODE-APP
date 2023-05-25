terraform {
  cloud {
    organization = "nginxTerraform"

    workspaces {
      name = "Pipeline_terraform2"
    }
  }
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.67.0"
    }
  }
}

provider "aws" {
  region     = var.AWS_REGION
}

