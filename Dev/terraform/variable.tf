variable "AWS_REGION" {
  default = "us-east-1"
}

variable "Security_Group" {
  type = list
  default = ["sg-24075", "sg-24076", "sg-24077"]
}

variable "AMIS" {
  type = map
  default = {
    us-east-1 = "ami-022e1a32d3f742bd8"
    us-east-2 = "ami-0b59bfac6be064b78"
    us-west-1 = "ami-a0cfeed8"
    us-west-2 = "ami-0bdb828fd58c52235"
  }
}

variable "PATH_TO_PRIVATE_KEY" {
  default = "my_terra_key"
}

variable "PATH_TO_PUBLIC_KEY" {
  default = "./my_terra_key.pub"
}

variable "INSTANCE_USERNAME" {
  default = "ubuntu"
}
