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

# terraform {
#   required_providers {                   
#     ansible = {
#       version = "~> 1.1.0"
#       source  = "ansible/ansible"
#     }
#     aws = {
#       source = "hashicorp/aws"
#       version = "~> 4.67.0"
#     }
#   }
# }

#provider "ansible" {}

resource "aws_vpc" "demo-vpc" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = "terra-demo"
  }
}

resource "aws_internet_gateway" "demo-gw" {
  vpc_id = aws_vpc.demo-vpc.id

  tags = {
    Name = "Demo"
  }
}

resource "aws_subnet" "demo-subnet" {
  vpc_id = aws_vpc.demo-vpc.id
  cidr_block = "172.16.0.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Demo-subnet"
  }
}

data "aws_route_table" "selected" {
  vpc_id = aws_vpc.demo-vpc.id
}

resource "aws_route" "demo-route" {
  route_table_id = data.aws_route_table.selected.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.demo-gw.id
}

resource "aws_network_interface" "demo" {
  subnet_id = aws_subnet.demo-subnet.id
  private_ips = ["172.16.0.100"] 
  security_groups = [aws_security_group.ingress-all-group.id]

  tags = {
    Name = "primary_network_interface"
  }
}

# resource "aws_eip" "demo-eip" {
#   vpc = true
# }

# resource "aws_eip_association" "demo-eip-asso" {
#   instance_id = aws_instance.Terraform_instance.id
#   allocation_id = aws_eip.demo-eip.id
# }

resource "aws_security_group" "ingress-all-group" {
  name = "ec2_node_sg"
  description = "allow http from everywhere"
  ingress {
    description = "ssh from everywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "http from everywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "all out"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  vpc_id = aws_vpc.demo-vpc.id
}

resource "aws_key_pair" "my_terra_key2" {
    key_name = "my_terra_key2"
    public_key = file("./my-pub-key")
}

resource "aws_instance" "Terraform_instance" {
  ami     = lookup(var.AMIS, var.AWS_REGION)
  instance_type  = "t2.micro"
  key_name = aws_key_pair.my_terra_key2.key_name
  availability_zone = "us-east-1a"
  associate_public_ip_address = true
  subnet_id = aws_subnet.demo-subnet.id
  vpc_security_group_ids = [ aws_security_group.ingress-all-group.id ]

  # network_interface {
  #   network_interface_id = aws_network_interface.demo.id
  #   device_index =  0
  # }

  tags = {
    Name   = "custom_instance"
  }

}

output "public_ip" {
  value = aws_instance.Terraform_instance.public_ip
}

# resource "ansible_vault" "secrets" {
#   vault_file  = "./vault.yaml"
#   vault_password_file  = "./password"
# }

# locals {
#   decoded_vault_yaml = yamldecode(ansible_vault.secrets.yaml)
# }

# resource "ansible_host" "my_ec2" {
#   name   = aws_instance.Terraform_instance.id
#   groups = ["webserver"]
#   variables = {
#     ansible_user                 = "ec2-user",
#     ansible_ssh_private_key_file = "/home/fikunmi/.ssh/id_rsa",
#     ansible_python_interpreter   = "/usr/bin/python3"
#     #yaml_secret  = local.decoded_vault_yaml.sensitive
#   }
# }

