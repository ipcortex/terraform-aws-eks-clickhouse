locals {
  region = "eu-west-2"
}

provider "aws" {
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs
  region = local.region
}

module "eks_clickhouse" {
  source  = "github.com/Altinity/terraform-aws-eks-clickhouse"

  install_clickhouse_operator = true
  install_clickhouse_cluster  = true

  # Set to true if you want to use a public load balancer (and expose ports to the public Internet)
  clickhouse_cluster_enable_loadbalancer = false

  eks_cluster_name = "clickhouse-cluster"
  eks_region       = local.region
  eks_cidr         = "172.31.0.0/16"

  eks_availability_zones = [
    "${local.region}a",
    "${local.region}b",
    "${local.region}c"
  ]
  eks_private_cidr = [
    "172.31.1.0/24",
    "172.31.2.0/24",
    "172.31.3.0/24"
  ]
  eks_public_cidr = [
    "172.31.101.0/24",
    "172.31.102.0/24",
    "172.31.103.0/24"
  ]

  eks_node_pools = [
    {
      name          = "clickhouse"
      instance_type = "t4g.medium"
      desired_size  = 0
      max_size      = 4
      min_size      = 0
      zones         = ["${local.region}a", "${local.region}b", "${local.region}c"]
    },
    {
      name          = "system"
      instance_type = "t4g.medium"
      desired_size  = 1
      max_size      = 4
      min_size      = 0
      zones         = ["${local.region}a"]
    }
  ]

  eks_tags = {
    CreatedBy = "Andrew"
  }
}
