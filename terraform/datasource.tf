data "aws_availability_zones" "node" {
  state = "available"
}

data "aws_ami" "node-amazon-linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-hvm-*-x86_64-ebs"]
  }
}