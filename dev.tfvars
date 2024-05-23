# Generic Variables
region = "us-east-1"
# VPC Configuration
vpc_id = "vpc-0a6cf673aa37f41b2"

# ID of the existing Private Subnets
vpc_spoke_public_subnet_ids = ["subnet-037c13388fd4ad82a", "subnet-0d6b9e156324f415e"]

vpc_spoke_private_subnet_ids=["subnet-087c7ebe8373d6d3c","subnet-0351c65e7eccfdc42"]

cluster_name = "eks"
cluster_service_ipv4_cidr = "172.20.0.0/16"
cluster_version = "1.28"
cluster_endpoint_private_access = true
cluster_endpoint_public_access = true
cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]
eks_oidc_root_ca_thumbprint = "9e99a48a9960b14926bb7f3b02e22da2b0ab7280"

# install_lbc_add_on value true will install the add-on, false will not
install_lbc_add_on = true

# install_efs_add_on value true will install the add-on, false will not
install_efs_add_on = true

business_division = "infra-prov"
environment = "dev"

vpc_cidr_block = "10.0.0.0/16"

#Fargate Variables
namespace= "fp-dev"

require_fargate_compute =true