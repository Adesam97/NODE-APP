module "module_eks" {
  source      = "./module-eks"
 
  cluster_name = var.cluster_name
  nodegroup_one_name = var.cluster_name
  vpc_subnet_ids = module.module_vpc.vpc_private_subnet_ids
}

module "module_vpc" {
  source      = "./module-vpc"

  vpc_name = var.vpc_name
  tag_cluster_name = var.cluster_name
}
