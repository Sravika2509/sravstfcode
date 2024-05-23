#--------------------------------------------------------
# Local Values in Terraform
#--------------------------------------------------------

locals {
  owners = var.business_division
  environment = var.environment
  name = "${var.business_division}-${var.environment}"
  #name = "${local.owners}-${local.environment}"
  common_tags = {
    owners = local.owners
    environment = local.environment
  }
  eks_cluster_name = "${local.name}-${var.cluster_name}"  
}

#--------------------------------------------------------
# Data block to fetch VPC ID
#--------------------------------------------------------
data "aws_vpc" "selected_vpc" {
  id = var.vpc_id
}


#--------------------------------------------------------
# VPC Subnet Tags
#--------------------------------------------------------
resource "aws_ec2_tag" "public_spoke_subnets_tag_eks_cluster" {
  for_each    = toset(var.vpc_spoke_public_subnet_ids)
  resource_id = each.value
  key         = "kubernetes.io/cluster/${local.eks_cluster_name}"
  value       = "shared"
}

resource "aws_ec2_tag" "public_spoke_subnets_tag_elb" {
  for_each    = toset(var.vpc_spoke_public_subnet_ids)
  resource_id = each.value
  key         = "kubernetes.io/role/elb"
  value       = "1"
}

resource "aws_ec2_tag" "private_spoke_subnets_tag_eks_cluster" {
  for_each    = toset(var.vpc_spoke_private_subnet_ids)
  resource_id = each.value
  key         = "kubernetes.io/cluster/${local.eks_cluster_name}"
  value       = "shared"
}

resource "aws_ec2_tag" "private_spoke_subnets_tag_elb" {
  for_each    = toset(var.vpc_spoke_private_subnet_ids)
  resource_id = each.value
  key         = "kubernetes.io/role/internal-elb"
  value       = "1"
}


#--------------------------------------------------------
# VPC Endpoint for EC2
#--------------------------------------------------------
resource "aws_vpc_endpoint" "vpce-ec2" {
  policy = jsonencode(
    {
      Statement = [
        {
          Action    = "*"
          Effect    = "Allow"
          Principal = "*"
          Resource  = "*"
        },
      ]
    }
  )
  private_dns_enabled = true
  route_table_ids     = []
  security_group_ids = [ aws_security_group.sg_allow_from_EKS.id ]
  service_name = format("com.amazonaws.%s.ec2",var.region)
  subnet_ids = var.vpc_spoke_private_subnet_ids
  vpc_endpoint_type = "Interface"
  vpc_id            = var.vpc_id
  tags = {
    Name = "${local.name}-vpce-ec2"  
    owners = local.owners
    environment = local.environment
  }
  timeouts {}
}


#--------------------------------------------------------
# VPC Endpoint for ECR-API
#--------------------------------------------------------
resource "aws_vpc_endpoint" "vpce-ecrapi" {
  policy = jsonencode(
    {
      Statement = [
        {
          Action    = "*"
          Effect    = "Allow"
          Principal = "*"
          Resource  = "*"
        },
      ]
    }
  )
  private_dns_enabled = true
  route_table_ids     = []
  security_group_ids = [ aws_security_group.sg_allow_from_EKS.id ]
  service_name = format("com.amazonaws.%s.ecr.api",var.region)
  subnet_ids = var.vpc_spoke_private_subnet_ids
  vpc_endpoint_type = "Interface"
  vpc_id            = var.vpc_id
  tags = {
    Name = "${local.name}-vpce-ecrapi"  
    owners = local.owners
    environment = local.environment
  }

  timeouts {}
}

#--------------------------------------------------------
# VPC Endpoint for ECR DKR
#--------------------------------------------------------
resource "aws_vpc_endpoint" "vpce-ecrdkr" {
  policy = jsonencode(
    {
      Statement = [
        {
          Action    = "*"
          Effect    = "Allow"
          Principal = "*"
          Resource  = "*"
        },
      ]
    }
  )
  private_dns_enabled = true
  route_table_ids     = []
  security_group_ids = [ aws_security_group.sg_allow_from_EKS.id ]
  service_name = format("com.amazonaws.%s.ecr.dkr",var.region)
  subnet_ids = var.vpc_spoke_private_subnet_ids
  vpc_endpoint_type = "Interface"
  vpc_id            = var.vpc_id

  tags = {
    Name = "${local.name}-vpce-ecrdkr"  
    owners = local.owners
    environment = local.environment
  }

  timeouts {}
}

#--------------------------------------------------------
# VPC Endpoint for sts
#--------------------------------------------------------
resource "aws_vpc_endpoint" "vpce-sts" {
  policy = jsonencode(
    {
      Statement = [
        {
          Action    = "*"
          Effect    = "Allow"
          Principal = "*"
          Resource  = "*"
        },
      ]
    }
  )
  private_dns_enabled = true
  route_table_ids     = []
  security_group_ids = [ aws_security_group.sg_allow_from_EKS.id ]
  service_name = format("com.amazonaws.%s.sts",var.region)
  subnet_ids = var.vpc_spoke_private_subnet_ids
  vpc_endpoint_type = "Interface"
  vpc_id            = var.vpc_id

  tags = {
    Name = "${local.name}-vpce-sts"  
    owners = local.owners
    environment = local.environment
  }

  timeouts {}
}

#--------------------------------------------------------
# VPC Endpoint for EFS
#--------------------------------------------------------
resource "aws_vpc_endpoint" "vpce-efs" {
  policy = jsonencode(
    {
      Statement = [
        {
          Action    = "*"
          Effect    = "Allow"
          Principal = "*"
          Resource  = "*"
        },
      ]
    }
  )
  private_dns_enabled = true
  route_table_ids     = []
  security_group_ids = [ aws_security_group.sg_allow_from_EKS.id ]
  service_name = format("com.amazonaws.%s.elasticfilesystem",var.region)
  subnet_ids = var.vpc_spoke_private_subnet_ids
  vpc_endpoint_type = "Interface"
  vpc_id            = var.vpc_id

  tags = {
    Name = "${local.name}-vpce-efs"  
    owners = local.owners
    environment = local.environment
  }

  timeouts {}
}


data "aws_route_table" "private_RT_subnet_0" {
  subnet_id = var.vpc_spoke_private_subnet_ids[0] 
}

data "aws_route_table" "private_RT_subnet_1" {
  subnet_id = var.vpc_spoke_private_subnet_ids[1]
}

# ARN ID
output "arn_id_of_pvt_subnet_0" {
  description = "The ARN ID of the RT assigned to Private Subnet 0"
  value       = data.aws_route_table.private_RT_subnet_0.arn
}

output "arn_id_of_pvt_subnet_1" {
  description = "The ARN ID of the RT assigned to Private Subnet 1"
  value       = data.aws_route_table.private_RT_subnet_1.arn
}

#--------------------------------------------------------
# VPC Endpoint for S3
#--------------------------------------------------------
resource "aws_vpc_endpoint" "vpce-s3" {
  policy = jsonencode(
    {
      Statement = [
        {
          Action    = "s3:*"
          Effect    = "Allow"
          Principal = "*"
          Resource  = "*"
        },
      ]
      Version = "2008-10-17"
    }
  )
  private_dns_enabled = false
  route_table_ids = [ data.aws_route_table.private_RT_subnet_0.id, data.aws_route_table.private_RT_subnet_1.id]
  security_group_ids = []
  service_name       = format("com.amazonaws.%s.s3",var.region)
  subnet_ids         = []
  vpc_endpoint_type  = "Gateway"
  vpc_id             = var.vpc_id

  tags = {
    Name = "${local.name}-vpce-s3"  
    owners = local.owners
    environment = local.environment
  }

  timeouts {}
}


#--------------------------------------------------------
# Security Group for EKS Node Group
# Outbound port 443 should be allowed
#--------------------------------------------------------

resource "aws_security_group" "sg_allow_eks_nodes" {
  name        = "${local.name}-allow_eks_node_ports"
  description = "Allow EKS Node Ports inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description      = "Allow EKS Node Ports"
    from_port        = 30000
    to_port          = 65000
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

#--------------------------------------------------------
# Create AWS EKS Cluster
#--------------------------------------------------------
resource "aws_eks_cluster" "eks_cluster" {
  name     = "${local.name}-${var.cluster_name}"
  role_arn = aws_iam_role.eks_master_role.arn
  version = var.cluster_version

  vpc_config {
    subnet_ids = var.vpc_spoke_public_subnet_ids
    endpoint_private_access = var.cluster_endpoint_private_access
    endpoint_public_access  = var.cluster_endpoint_public_access
    public_access_cidrs     = var.cluster_endpoint_public_access_cidrs
    security_group_ids      = [ aws_security_group.sg_allow_eks_nodes.id ]
  }

  kubernetes_network_config {
    service_ipv4_cidr = var.cluster_service_ipv4_cidr
  }
  
  # Enable EKS Cluster Control Plane Logging
  #enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.eks-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks-AmazonEKSVPCResourceController,
  ]
}

#--------------------------------------------------------
# Create Private Key used to login to EKS Nodes
#--------------------------------------------------------

resource "tls_private_key" "pk" {
  algorithm     = "RSA"
  rsa_bits      = 4096
}

resource "aws_key_pair" "kp" {
  key_name      = "eks-terraform-key-${var.region}"
  public_key    = trimspace(tls_private_key.pk.public_key_openssh)
}

resource "local_file" "ssh_key" {
  filename = "${path.module}/private-key/${aws_key_pair.kp.key_name}.pem"
  content = tls_private_key.pk.private_key_pem
  file_permission = "0400"
}

#--------------------------------------------------------
# Create AWS EKS Node Group - Private
#--------------------------------------------------------

resource "aws_eks_node_group" "eks_ng_private" {
  cluster_name    = aws_eks_cluster.eks_cluster.name

  node_group_name = "${local.name}-eks-ng-private"
  node_role_arn   = aws_iam_role.eks_nodegroup_role.arn
  subnet_ids      = var.vpc_spoke_private_subnet_ids
  version = var.cluster_version #(Optional: Defaults to EKS Cluster Kubernetes version)   
  
  ami_type = "AL2_x86_64"  
  capacity_type = "ON_DEMAND"
  disk_size = 20
  instance_types = ["t3.medium"]
  
  
  remote_access {
    ec2_ssh_key = "eks-terraform-key-${var.region}"
    source_security_group_ids =  [ aws_security_group.sg_allow_eks_nodes.id ]
  }

  scaling_config {
    desired_size = 2
    min_size     = 1    
    max_size     = 2
  }

  # Desired max percentage of unavailable worker nodes during node group update.
  update_config {
    max_unavailable = 1    
    #max_unavailable_percentage = 50    # ANY ONE TO USE
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.eks-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks-AmazonEC2ContainerRegistryReadOnly
  ] 
  tags = {
    Name = "Private-Node-Group"
    "kubernetes.io/cluster/${local.eks_cluster_name}" = "owned"
  }
}


#--------------------------------------------------------
# Create IAM Role
#--------------------------------------------------------
resource "aws_iam_role" "eks_master_role" {
  name = "${local.name}-eks-master-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

#--------------------------------------------------------
# Associate IAM Policy to IAM Role
#--------------------------------------------------------
resource "aws_iam_role_policy_attachment" "eks-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_master_role.name
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_master_role.name
}

/*
# Optionally, enable Security Groups for Pods
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
resource "aws_iam_role_policy_attachment" "eks-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_master_role.name
}
*/

#--------------------------------------------------------
# Security Group for EKS Node Group
#--------------------------------------------------------
resource "aws_security_group" "sg_allow_from_EKS" {
  name        = "${local.name}-sg-allow-from-EKS-to-VPCE"
  description = "Allow 443 traffic from EKS Node to VPCE"
  vpc_id      = var.vpc_id

  ingress {
    description      = "Allow 443 from EKS Node to VPCE"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    security_groups  = [ aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id ]
  }

  egress {
    description      = "Allow all outbound traffic from EKS Node to VPCE"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

#--------------------------------------------------------
# IAM Role for EKS Node Group
#--------------------------------------------------------
resource "aws_iam_role" "eks_nodegroup_role" {
  name = "${local.name}-eks-nodegroup-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodegroup_role.name
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodegroup_role.name
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodegroup_role.name
}

#--------------------------------------------------------
# IAM OIDC Connect Provider
#--------------------------------------------------------

# Datasource: AWS Partition
# Use this data source to lookup information about the current AWS partition in which Terraform is working
data "aws_partition" "current" {}

# Resource: AWS IAM Open ID Connect Provider
resource "aws_iam_openid_connect_provider" "oidc_provider" {
  client_id_list  = ["sts.${data.aws_partition.current.dns_suffix}"]
  thumbprint_list = [var.eks_oidc_root_ca_thumbprint]
  url             = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer

  tags = merge(
    {
      Name = "${var.cluster_name}-eks-irsa"
    },
    local.common_tags
  )
}

# Output: AWS IAM Open ID Connect Provider ARN
output "aws_iam_openid_connect_provider_arn" {
  description = "AWS IAM Open ID Connect Provider ARN"
  value = aws_iam_openid_connect_provider.oidc_provider.arn 
}

# Extract OIDC Provider from OIDC Provider ARN
locals {
    aws_iam_oidc_connect_provider_extract_from_arn = element(split("oidc-provider/", "${aws_iam_openid_connect_provider.oidc_provider.arn}"), 1)
}
# Output: AWS IAM Open ID Connect Provider
output "aws_iam_openid_connect_provider_extract_from_arn" {
  description = "AWS IAM Open ID Connect Provider extract from ARN"
   value = local.aws_iam_oidc_connect_provider_extract_from_arn
}

# Datasource: 
data "aws_eks_cluster_auth" "cluster" {
  name = aws_eks_cluster.eks_cluster.id
}

#--------------------------------------------------------
# Install Load Balancer Controller Add-on
#--------------------------------------------------------

# Datasource: AWS Load Balancer Controller IAM Policy get from aws-load-balancer-controller/ GIT Repo (latest)
data "http" "lbc_iam_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json"

  # Optional request headers
  request_headers = {
    Accept = "application/json"
  }
}

/*
output "lbc_iam_policy" {
  value = data.http.lbc_iam_policy.response_body
}
*/


# Resource: Create AWS Load Balancer Controller IAM Policy 
resource "aws_iam_policy" "lbc_iam_policy" {
  count = var.install_lbc_add_on ? 1 : 0
  name        = "${local.name}-AWSLoadBalancerControllerIAMPolicy"
  path        = "/"
  description = "AWS Load Balancer Controller IAM Policy"
  policy = data.http.lbc_iam_policy.response_body
}

output "lbc_iam_policy_arn" {
  value = var.install_lbc_add_on ? aws_iam_policy.lbc_iam_policy[0].arn : null
}

# Resource: Create IAM Role 
resource "aws_iam_role" "lbc_iam_role" {
  count = var.install_lbc_add_on ? 1 : 0
  name = "${local.name}-lbc-iam-role"

  # Terraform's "jsonencode" function converts a Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Federated = "${aws_iam_openid_connect_provider.oidc_provider.arn}"
        }
        Condition = {
          StringEquals = {
            "${local.aws_iam_oidc_connect_provider_extract_from_arn}:aud": "sts.amazonaws.com",            
            "${local.aws_iam_oidc_connect_provider_extract_from_arn}:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }        
      },
    ]
  })

  tags = {
    tag-key = "AWSLoadBalancerControllerIAMPolicy"
  }
}

# Associate Load Balanacer Controller IAM Policy to  IAM Role
resource "aws_iam_role_policy_attachment" "lbc_iam_role_policy_attach" {
  count = var.install_lbc_add_on ? 1 : 0
  policy_arn = aws_iam_policy.lbc_iam_policy[0].arn 
  role       = aws_iam_role.lbc_iam_role[0].name
}

output "lbc_iam_role_arn" {
  description = "AWS Load Balancer Controller IAM Role ARN"
  value = var.install_lbc_add_on ? aws_iam_role.lbc_iam_role[0].arn : null
}

# HELM Provider
provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.eks_cluster.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.eks_cluster.certificate_authority[0].data)
    #token                  = data.aws_eks_cluster_auth.cluster.token
    exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.eks_cluster.name]
    command     = "aws"
  }
    #config_path = "~/.kube/config"
  }
}

# Install AWS Load Balancer Controller using HELM

# Resource: Helm Release 
resource "helm_release" "loadbalancer_controller" {
  count = var.install_lbc_add_on ? 1 : 0
  depends_on = [aws_iam_role.lbc_iam_role]
  name       = "aws-load-balancer-controller"

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"

  namespace = "kube-system"     

  # Value changes based on your Region (Below is for us-east-1)
  # ECR link changes based on the region - https://docs.aws.amazon.com/eks/latest/userguide/add-ons-images.html
  set {
    name = "image.repository"
    value = format("602401143452.dkr.ecr.%s.amazonaws.com/amazon/aws-load-balancer-controller",var.region)
    #value = "602401143452.dkr.ecr.us-east-1.amazonaws.com/amazon/aws-load-balancer-controller" 
  
  }       

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = "${aws_iam_role.lbc_iam_role[0].arn}"
  }

  set {
    name  = "vpcId"
    value = "${var.vpc_id}"
  }  

  set {
    name  = "region"
    value = "${var.region}"
  }    

  set {
    name  = "clusterName"
    value = "${aws_eks_cluster.eks_cluster.id}"
  }    
    
}

# Helm Release Outputs
/*
Commented as it is giving very long output
output "lbc_helm_metadata" {
  description = "Metadata Block outlining status of the deployed release."
  value = helm_release.loadbalancer_controller.metadata
}
*/

#--------------------------------------------------------
# Install EFS Add-on
#--------------------------------------------------------

# Datasource: EFS CSI IAM Policy get from EFS GIT Repo (latest)
data "http" "efs_csi_iam_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-efs-csi-driver/master/docs/iam-policy-example.json"

  # Optional request headers
  request_headers = {
    Accept = "application/json"
  }
}

/*
Commented out - as it is giving very long output
output "efs_csi_iam_policy" {
  value = data.http.efs_csi_iam_policy.response_body
}
*/


# Resource: Create EFS CSI IAM Policy 
resource "aws_iam_policy" "efs_csi_iam_policy" {
  count = var.install_efs_add_on ? 1 : 0
  name        = "${local.name}-AmazonEKS_EFS_CSI_Driver_Policy"
  path        = "/"
  description = "EFS CSI IAM Policy"
  policy = data.http.efs_csi_iam_policy.response_body
}

/*
output "efs_csi_iam_policy_arn" {
  value = aws_iam_policy.efs_csi_iam_policy.arn 
}
*/

# Resource: Create IAM Role and associate the EFS IAM Policy to it
resource "aws_iam_role" "efs_csi_iam_role" {
  count = var.install_efs_add_on ? 1 : 0
  name = "${local.name}-efs-csi-iam-role"

  # Terraform's "jsonencode" function converts a Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Federated = "${aws_iam_openid_connect_provider.oidc_provider.arn}"
        }
        Condition = {
          StringEquals = {
            "${local.aws_iam_oidc_connect_provider_extract_from_arn}:sub": "system:serviceaccount:kube-system:efs-csi-controller-sa"
          }
        }        
      },
    ]
  })

  tags = {
    tag-key = "efs-csi"
  }
}

# Associate EFS CSI IAM Policy to EFS CSI IAM Role
resource "aws_iam_role_policy_attachment" "efs_csi_iam_role_policy_attach" {
  count = var.install_efs_add_on ? 1 : 0
  policy_arn = aws_iam_policy.efs_csi_iam_policy[0].arn 
  role       = aws_iam_role.efs_csi_iam_role[0].name
}

output "efs_csi_iam_role_arn" {
  description = "EFS CSI IAM Role ARN"
  value = var.install_efs_add_on ? aws_iam_role.efs_csi_iam_role[0].arn : null
}

# Install EFS CSI Driver using HELM

# Resource: Helm Release 
resource "helm_release" "efs_csi_driver" {
  count = var.install_efs_add_on ? 1 : 0
  depends_on = [aws_iam_role.efs_csi_iam_role, kubernetes_service_account_v1.efs-sa1 ]            
  name       = "aws-efs-csi-driver"

  repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver"
  chart      = "aws-efs-csi-driver"

  namespace = "kube-system"     

  set {
    name = "image.repository"
    value = format("602401143452.dkr.ecr.%s.amazonaws.com/eks/aws-efs-csi-driver", var.region)
    # Changes based on Region - Additional Reference: https://docs.aws.amazon.com/eks/latest/userguide/add-ons-images.html
  }       

  set {
    name  = "controller.serviceAccount.create"
    value = "false"
  }

  set {
    name  = "controller.serviceAccount.name"
    value = "${kubernetes_service_account_v1.efs-sa1[0].metadata[0].name}"
  }

  set {
    name  = "sidecars.livenessProbe.image.repository"
    value = format("602401143452.dkr.ecr.%s.amazonaws.com/eks/livenessprobe", var.region)
  }

  set {
    #name  = "sidecars.node-driver-registrar.image.repository"
    name  = "sidecars.nodeDriverRegistrar.image.repository"
    value = format("602401143452.dkr.ecr.%s.amazonaws.com/eks/csi-node-driver-registrar", var.region)
  }

  set {
    name  = "sidecars.csiProvisioner.image.repository"
    value = format("602401143452.dkr.ecr.%s.amazonaws.com/eks/csi-provisioner", var.region)
  }

  /*
  set {
    name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = "${aws_iam_role.efs_csi_iam_role.arn}"
  }
  */
    
}


resource "kubernetes_service_account_v1" "efs-sa1" {
  count = var.install_efs_add_on ? 1 : 0
  metadata {
        labels = {
            "app.kubernetes.io/name" = "aws-efs-csi-driver"
        }
        name = "${local.name}-efs-csi-controller-sa"
        namespace = "kube-system"
        annotations = {
            "eks.amazonaws.com/role-arn" = "${aws_iam_role.efs_csi_iam_role[0].arn}"
        }
    }
}


# Resource: Security Group - Allow Inbound NFS Traffic from EKS VPC CIDR to EFS File System
resource "aws_security_group" "efs_allow_access" {
  count = var.install_efs_add_on ? 1 : 0
  name        = "${local.name}-efs-allow-nfs-from-eks-vpc"
  description = "Allow Inbound NFS Traffic from EKS VPC CIDR"
  vpc_id      = var.vpc_id

  ingress {
    description      = "Allow Inbound NFS Traffic from EKS VPC CIDR to EFS File System"
    from_port        = 2049
    to_port          = 2049
    protocol         = "tcp"
    cidr_blocks      = [var.vpc_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name}-allow-nfs-from-eks-vpc-sg"
  }
}


# Resource: EFS File System
resource "aws_efs_file_system" "efs_file_system" {
  count = var.install_efs_add_on ? 1 : 0
  creation_token = "${local.name}-efs"
  tags = {
    Name = "${local.name}-efs"
  }
}

# Resource: EFS Mount Target
resource "aws_efs_mount_target" "efs_mount_target" {
  count = var.install_efs_add_on ? 2 : 0
  file_system_id = aws_efs_file_system.efs_file_system[0].id
  subnet_id      = var.vpc_spoke_private_subnet_ids[count.index]
  security_groups = [ aws_security_group.efs_allow_access[0].id ]
}



# EFS File System ID
output "efs_file_system_id" {
  description = "EFS File System ID"
  value = var.install_efs_add_on ? aws_efs_file_system.efs_file_system[0].id : null
}

output "efs_file_system_dns_name" {
  description = "EFS File System DNS Name"
  value = var.install_efs_add_on ? aws_efs_file_system.efs_file_system[0].dns_name : null
}


# EFS Mounts Info
output "efs_mount_target_id" {
  description = "EFS File System Mount Target ID"
  value = aws_efs_mount_target.efs_mount_target[*].id 
}

output "efs_mount_target_dns_name" {
  description = "EFS File System Mount Target DNS Name"
  value = aws_efs_mount_target.efs_mount_target[*].mount_target_dns_name 
}

output "efs_mount_target_availability_zone_name" {
  description = "EFS File System Mount Target availability_zone_name"
  value = aws_efs_mount_target.efs_mount_target[*].availability_zone_name 
}

# Adding Fargate Logic configurable
resource "aws_eks_fargate_profile" "fargate_profile" {
  count = var.require_fargate_compute ? 1 : 0
  cluster_name           = aws_eks_cluster.eks_cluster.name
  fargate_profile_name   = "${local.name}-fargate-profile"
  pod_execution_role_arn = aws_iam_role.eks-fargate-profile[0].arn
  subnet_ids = var.vpc_spoke_private_subnet_ids

  selector {
    namespace = var.namespace
  }
}

# IAM for fargate

resource "aws_iam_role" "eks-fargate-profile" {
  count = var.require_fargate_compute ? 1 : 0
  name = "${local.name}-eks-fargate-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks-fargate-pods.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "eks-fargate-profile" {
  count = var.require_fargate_compute ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.eks-fargate-profile[0].name
}