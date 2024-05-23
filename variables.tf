variable "vpc_id" {
  type = string
  default = "vpc-0731900d6bd65b956"
  description = "VPC Id"
}

# VPC Public Subnets
variable "vpc_public_subnets" {
  description = "VPC Public Subnets"
  type = list(string)
  default = ["10.0.101.0/24", "10.0.102.0/24"]
}

# VPC Private Subnets
variable "vpc_private_subnets" {
  description = "VPC Private Subnets"
  type = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

# EKS Cluster Input Variables
variable "cluster_name" {
  description = "Name of the EKS cluster. Also used as a prefix in names of related resources."
  type        = string
  default     = "eksdemo"
}

variable "cluster_service_ipv4_cidr" {
  description = "service ipv4 cidr for the kubernetes cluster"
  type        = string
  default     = null
}

variable "cluster_version" {
  description = "Kubernetes minor version to use for the EKS cluster (for example 1.21)"
  type = string
  default     = null
}
variable "cluster_endpoint_private_access" {
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled."
  type        = bool
  default     = false
}

variable "cluster_endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled. When it's set to `false` ensure to have a proper private access with `cluster_endpoint_private_access = true`."
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "List of CIDR blocks which can access the Amazon EKS public API server endpoint."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# EKS OIDC ROOT CA Thumbprint - valid until 2037 - AWS IAM OIDC Connect Provider
variable "eks_oidc_root_ca_thumbprint" {
  type        = string
  description = "Thumbprint of Root CA for EKS OIDC, Valid until 2037"
  default     = "9e99a48a9960b14926bb7f3b02e22da2b0ab7280"
}

# Business Division
variable "business_division" {
  description = "Business Division in the large organization this Infrastructure belongs"
  type = string
  default = "infra-prov"
}

# Environment Variable
variable "environment" {
  description = "Environment Variable used as a prefix"
  type = string
  default = "dev"
}

variable "vpc_spoke_public_subnet_ids" {
 type        = list(string)
 description = "Public Subnet values"
 default     = ["subnet-032dca3fa06cbe664", "subnet-086f0897ba979f3d8"]
}

variable "vpc_spoke_private_subnet_ids" {
 type        = list(string)
 description = "Private Subnet values"
 default     = ["subnet-01437bb00ba9cf0f9", "subnet-0135a0da32508730e"]
}


variable "region" {
  type        = string
  description = "AWS Region"
  default     = "us-east-1"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A mapping of tags which should be assigned to the resource"
}

# Boolean indicator to install lbc add-on
variable "install_lbc_add_on" {
  description = "Boolean variable to install Load Balancer Add-on"
  type = bool
  default = false
}

# VPC CIDR Block
variable "vpc_cidr_block" {
  description = "VPC CIDR Block"
  type = string 
  default = "10.0.0.0/16"
}

# Boolean indicator to install lbc add-on
variable "install_efs_add_on" {
  description = "Boolean variable to install EFS Add-on"
  type = bool
  default = false
}

variable "require_fargate_compute" {
  description = "Boolean variable to add Fargate compute to cluster"
  type = bool
  default = false
}

variable "namespace" {
  description = "Name of the namespace in which fargate pods gets created"
  type=string
  default = "fp-dev"
  
}