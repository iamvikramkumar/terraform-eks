# Define IAM Role for EKS Cluster
resource "aws_iam_role" "eks_cluster" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

# Attach AmazonEKSClusterPolicy to IAM Role
resource "aws_iam_policy_attachment" "eks_cluster_policy" {
  name       = "eks-cluster-policy"
  roles      = [aws_iam_role.eks_cluster.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# Get default VPC id
data "aws_vpc" "default" {
  default = true
}

# Get public subnets in VPC
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Create EKS Cluster
resource "aws_eks_cluster" "eks" {
  name     = "my-eks-cluster"
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids = data.aws_subnets.public.ids
  }
  
  # Specify additional configuration for multi-AZ
  depends_on = [data.aws_subnets.public]
}

# Define IAM Role for EKS Node Group 1
resource "aws_iam_role" "example1" {
  name = "eks-node-group-example1"

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

# Attach policies to IAM Role for EKS Node Group 1
resource "aws_iam_role_policy_attachment" "example1-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.example1.name
}

resource "aws_iam_role_policy_attachment" "example1-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.example1.name
}

resource "aws_iam_role_policy_attachment" "example1-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.example1.name
}

# Create managed node group 1
resource "aws_eks_node_group" "example1" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "managed-nodes-1"
  node_role_arn   = aws_iam_role.example1.arn

  subnet_ids = data.aws_subnets.public.ids
  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 2
  }
  instance_types = ["t2.micro"]

  depends_on = [
    aws_iam_role_policy_attachment.example1-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.example1-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.example1-AmazonEC2ContainerRegistryReadOnly,
    aws_eks_cluster.eks
  ]
}

# Define IAM Role for EKS Node Group 2
resource "aws_iam_role" "example2" {
  name = "eks-node-group-example2"

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

# Attach policies to IAM Role for EKS Node Group 2
resource "aws_iam_role_policy_attachment" "example2-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.example2.name
}

resource "aws_iam_role_policy_attachment" "example2-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.example2.name
}

resource "aws_iam_role_policy_attachment" "example2-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.example2.name
}

# Create managed node group 2
resource "aws_eks_node_group" "example2" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "managed-nodes-2"
  node_role_arn   = aws_iam_role.example2.arn

  subnet_ids = data.aws_subnets.public.ids
  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 2
  }
  instance_types = ["t2.micro"]

  depends_on = [
    aws_iam_role_policy_attachment.example2-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.example2-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.example2-AmazonEC2ContainerRegistryReadOnly,
    aws_eks_cluster.eks
  ]
}