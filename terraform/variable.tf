variable "AWS_REGION" {
  default = "us-east-1"
}

variable "subnet_cidr_blocks" {
  default = ["10.10.1.0/24", "10.10.2.0/24"]
}

variable "vpc_cidr_block" {
  default = ["10.10.0.0/16"]
}

variable "Environment" {
  description = "environment of deployment"
  type = string
  default = ""
}

variable "no-of-instance" {
    description = "value to be deploy"
    type = map
    default = {
        local-test   = "1"
        development  = "1"
        testing      = "2"
        production   = "3"
    }
}