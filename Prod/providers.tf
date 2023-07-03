
terraform {
  cloud {
    organization = "aws-my-linux"

    workspaces {
      tags = [ "local" ]
    }
  }
  required_providers {
    aws = {
      version = ">= 4.40.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
}