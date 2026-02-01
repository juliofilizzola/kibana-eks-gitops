variable "cluster_name" { default = "kibana-cluster" }
variable "region" { default = "us-east-1" }  # Mude para sa-east-1 se preferir BR
variable "vpc_cidr" { default = "10.0.0.0/16" }
variable "environment" { default = "dev" }