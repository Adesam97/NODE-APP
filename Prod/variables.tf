variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "node-cluster"
}

variable "vpc_name" {
  description = "VPC name"
  type        = string
  default     = "eks-node-vpc"
}
