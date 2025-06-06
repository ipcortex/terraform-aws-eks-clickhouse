################################################################################
# GLOBAL
################################################################################
variable "install_clickhouse_cluster" {
  description = "Enable the installation of the ClickHouse cluster"
  type        = bool
  default     = true
}

variable "install_clickhouse_operator" {
  description = "Enable the installation of the Altinity Kubernetes operator for ClickHouse"
  type        = bool
  default     = true
}

variable "aws_profile" {
  description = "AWS profile of deployed cluster."
  type        = string
  default     = null
}

################################################################################
# ClickHouse Operator
################################################################################
variable "clickhouse_operator_namespace" {
  description = "Namespace to install the Altinity Kubernetes operator for ClickHouse"
  default     = "kube-system"
  type        = string
}

variable "clickhouse_operator_version" {
  description = "Version of the Altinity Kubernetes operator for ClickHouse"
  default     = "0.24.4"
  type        = string
}

################################################################################
# ClickHouse Cluster
################################################################################
variable "clickhouse_cluster_name" {
  description = "Name of the ClickHouse cluster"
  default     = "dev"
  type        = string
}

variable "clickhouse_cluster_namespace" {
  description = "Namespace of the ClickHouse cluster"
  default     = "clickhouse"
  type        = string
}

variable "clickhouse_cluster_user" {
  description = "ClickHouse user"
  default     = "test"
  type        = string
}

variable "clickhouse_cluster_password" {
  description = "ClickHouse password"
  type        = string
  default     = null
}

variable "clickhouse_cluster_enable_loadbalancer" {
  description = "Enable waiting for the ClickHouse LoadBalancer to receive a hostname"
  type        = bool
  default     = false
}

variable "clickhouse_cluster_chart_version" {
  description = "Version of the ClickHouse cluster helm chart version"
  default     = "0.1.8"
  type        = string
}

variable "clickhouse_keeper_chart_version" {
  description = "Version of the ClickHouse Keeper cluster helm chart version"
  default     = "0.1.4"
  type        = string
}

################################################################################
# EKS
################################################################################
variable "eks_region" {
  description = "The AWS region"
  type        = string
  default     = "eu-west-2"
}

variable "eks_cluster_name" {
  description = "The name of the cluster"
  type        = string
  default     = "clickhouse-cluster"
}

variable "eks_cluster_version" {
  description = "Version of the cluster"
  type        = string
  default     = "1.32"
}

variable "eks_autoscaler_version" {
  description = "Version of AWS Autoscaler"
  type        = string
  default     = "1.32.0"
}

variable "eks_autoscaler_replicas" {
  description = "Number of replicas for AWS Autoscaler"
  type        = number
  default     = 1
}

variable "autoscaler_replicas" {
  description = "Autoscaler replicas"
  type        = number
  default     = 1
}

variable "eks_tags" {
  description = "A map of AWS tags"
  type        = map(string)
  default     = {}
}

variable "eks_cidr" {
  description = "CIDR block"
  type        = string
  default     = "172.31.0.0/16"
}

variable "eks_node_pools" {
  description = "Node pools configuration. The module will create a node pool for each combination of instance type and subnet. For example, if you have 3 subnets and 2 instance types, this module will create 6 different node pools."

  type = list(object({
    name          = string
    instance_type = string
    ami_type      = optional(string)
    disk_size     = optional(number)
    desired_size  = number
    max_size      = number
    min_size      = number
    zones         = optional(list(string))

    labels = optional(map(string))
    taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })), [])
  }))

  default = [
    {
      name          = "clickhouse"
      instance_type = "t4g.medium"
      ami_type      = "AL2_ARM_64"
      desired_size  = 0
      disk_size     = 20
      max_size      = 10
      min_size      = 0
      zones         = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
    },
    {
      name          = "system"
      instance_type = "t4g.medium"
      ami_type      = "AL2_ARM_64"
      disk_size     = 20
      desired_size  = 1
      max_size      = 10
      min_size      = 0
      zones         = ["eu-west-2a"]
    }
  ]

  validation {
    condition = alltrue([
      for np in var.eks_node_pools :
      startswith(np.name, "clickhouse") || startswith(np.name, "system")
    ])
    error_message = "Each node pool name must start with either 'clickhouse' or 'system' prefix."
  }
}

variable "eks_enable_nat_gateway" {
  description = "Enable NAT Gateway and private subnets (recommeded)"
  type        = bool
  default     = true
}

variable "eks_private_cidr" {
  description = "List of private CIDR. When set, the number of private CIDRs must match the number of availability zones"
  type        = list(string)
  default = [
    "172.31.0.1.0/24",
    "172.31.2.0/24",
    "172.31.3.0/24"
  ]
}

variable "eks_public_cidr" {
  description = "List of public CIDR. When set, The number of public CIDRs must match the number of availability zones"
  type        = list(string)
  default = [
    "172.31.101.0/24",
    "172.31.102.0/24",
    "172.31.103.0/24"
  ]
}

variable "eks_availability_zones" {
  description = ""
  type        = list(string)
  default = [
    "eu-west-2a",
    "eu-west-2b",
    "eu-west-2c"
  ]
}

variable "eks_public_access_cidrs" {
  description = "List of CIDRs for public access, use this variable to restrict access to the EKS control plane."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
