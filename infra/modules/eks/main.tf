# The EKS cluster itself — this is the control plane
resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = var.cluster_role_arn

  vpc_config {
    subnet_ids              = var.private_subnet_ids  # control plane lives in private subnets
    endpoint_private_access = true   # kubectl works from inside the VPC
    endpoint_public_access  = true   # also accessible from your laptop
  }

  tags = {
    Name = var.cluster_name
  }
}

# Node group — the EC2 worker nodes that run your pods
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.cluster_name}-nodes"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.private_subnet_ids  # worker nodes in private subnets

  instance_types = [var.node_instance_type]

  scaling_config {
    desired_size = var.desired_nodes  # how many nodes to start with
    min_size     = var.min_nodes      # minimum when scaling down
    max_size     = var.max_nodes      # maximum when scaling up
  }

  update_config {
    max_unavailable = 1  # only take down 1 node at a time during updates
  }

  tags = {
    Name = "${var.cluster_name}-node-group"
  }
}
