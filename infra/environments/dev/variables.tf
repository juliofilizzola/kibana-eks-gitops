variable "node_instance_type" {
  type        = string                     # The type of the variable, in this case a string
  default     = "t2.micro"                 # Default value for the variable
  description = "The type of EC2 instance" # Description of what this variable represents
}

variable "environment" {
  type        = string
  default     = "dev"
  description = "The deployment environment (e.g., dev, staging, prod)"
}

variable "cluster_version" {
    type        = string
    default     = "1.21"
    description = "The version of the EKS cluster"
}

variable "vpc_cidr" {
    type        = string
    default     = "vpc CIDR block (e.g.,"
    description = "The CIDR block for the VPC"
}

variable "cluster_name" {
    type        = string
    default     = "eks-cluster"
    description = "The name of the EKS cluster"
}

variable "public_subnet_cidrs" {
  type=list(string)
  description = ""
}