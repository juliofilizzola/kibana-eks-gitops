provider "aws" {
  region = var.region
}

# ================= VPC =================
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.cluster_name}-vpc"
  cidr = var.vpc_cidr

  azs = [
    "${var.region}a",
    "${var.region}b",
    "${var.region}c"
  ]

  private_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24"
  ]

  public_subnets = [
    "10.0.101.0/24",
    "10.0.102.0/24",
    "10.0.103.0/24"
  ]

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb"                = 1
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"       = 1
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }

  tags = {
    Name = "${var.cluster_name}-vpc"
    Environment = var.environment
  }
}

# ================= EKS =================
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

      # Tags para node group
      tags = {
        Environment = var.environment
      }
    }
  }

  # ================= ACCESS ENTRIES =================
  access_entries = {
    eks_admin = {
      principal_arn = "arn:aws:iam::052775460750:role/EKSAdminRole"

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

# ================= DATA SOURCES =================
data "aws_eks_cluster" "cluster" {
  name       = module.eks.cluster_name
  depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "cluster" {
  name       = module.eks.cluster_name
  depends_on = [module.eks]
}

# ================= KUBERNETES PROVIDER =================
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  
  # FIX: Usa exec para tokens dinâmicos (resolve Unauthorized)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.cluster.name]
  }
}

# ================= HELM PROVIDER =================
provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    
    # FIX: Mesma config exec para Helm
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.cluster.name]
    }
  }
}

# ================= WAIT FOR NODES READY =================
# ================= WAIT FOR NODES READY =================
# resource "null_resource" "wait_for_nodes" {
#   triggers = {
#     cluster_name = module.eks.cluster_name
#   }

#   provisioner "local-exec" {
#     command = "aws eks wait nodegroup-active --cluster-name ${module.eks.cluster_name} --nodegroup-name general --region ${var.region} && aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.region} && sleep 30 && kubectl get nodes | grep -q 'Ready' || exit 1"
#   }

#   depends_on = [module.eks.eks_managed_node_groups]
# }


# ================= NAMESPACES =================
resource "kubernetes_namespace" "elastic" {
  metadata {
    name = "elastic-system"
  }

  depends_on = [
    # null_resource.wait_for_nodes,  # ← ADICIONE
    module.eks.eks_managed_node_groups
  ]
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }

  depends_on = [
    # null_resource.wait_for_nodes,  # ← ADICIONE
    data.aws_eks_cluster.cluster
  ]
}

# ================= ARGO CD =================
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "6.6.5"

  namespace = kubernetes_namespace.argocd.metadata[0].name

  depends_on = [
    kubernetes_namespace.argocd,
    module.eks.eks_managed_node_groups  # Nodes devem estar ready
  ]

  set {
    name  = "server.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "server.insecure"  # Desabilite em prod após acessar e setar senha
    value = "true"
  }
}
