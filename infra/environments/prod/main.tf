module "vpc" {
    source ="../../modules/vpc"
    env_name = var.environment
    cidr_block = var.vpc_cidr
    public_subnet_cidrs = var.public_subnet_cidrs
}

module "eks" {
    source = "../../modules/eks"
    env_name = var.environment
    vpc_id = module.vpc.vpc_id
    public_subnet_ids = module.vpc.public_subnet_ids
    cluster_version = var.cluster_version
    cluster_name = "${var.cluster_name}-${var.environment}"
    node_instance_type = var.node_instance_type
}
