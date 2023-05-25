terraform {
  cloud {
    organization = "aws-my-linux"

    workspaces {
      tags = [ "local" ]
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

