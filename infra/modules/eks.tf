module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.24"

  cluster_name    = var.cluster_name
  cluster_version = "1.30"

  cluster_endpoint_public_access = true
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  enable_irsa = true

  eks_managed_node_groups = {
    general = {
      name            = "general"
      use_name_prefix = false

      min_size     = 1
      max_size     = 3
      desired_size = 2

      instance_types = ["t3.medium"]

      tags = {
        Environment = var.environment
      }
    }
  }

  access_entries = {
    eks_admin = {
      principal_arn = "arn:aws:iam::367265287622:user/BPTECH-DEVOSP"

      policy_associations = {
        cluster_admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  tags = {
    Environment = var.environment
  }
}
