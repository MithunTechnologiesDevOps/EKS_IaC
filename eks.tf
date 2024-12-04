resource "aws_iam_role" "eksrole" {
  name               = "${local.nametag_prefix}-eks-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = merge(var.common_tags, { "Name" : "${local.nametag_prefix}-eks-cluster-role" })
}

resource "aws_iam_role_policy_attachment" "eksclustrole-policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eksrole.name
}

resource "aws_eks_cluster" "main" {

  name     = "${local.nametag_prefix}-eks-cluster"
  version  = "1.30"
  role_arn = aws_iam_role.eksrole.arn

  vpc_config {
    subnet_ids              = flatten([aws_subnet.private_subents[*].id, aws_subnet.public_subents[*].id])
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]
  }

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }
  tags       = merge(var.common_tags, { "Name" : "${local.nametag_prefix}-eks-cluster" })
  depends_on = [aws_iam_role_policy_attachment.eksclustrole-policy_attachment]
}

resource "aws_iam_role" "eksworkerrole" {
  name               = "${local.nametag_prefix}-eks-worker-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_worker.json
  tags               = merge(var.common_tags, { "Name" : "${local.nametag_prefix}-eks-worker-role" })
}

resource "aws_iam_role_policy_attachment" "workerrole_policy_attachment" {
  count      = length(var.eks_worker_role_policy_arns)
  role       = aws_iam_role.eksworkerrole.name
  policy_arn = element(var.eks_worker_role_policy_arns, count.index)
}

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${local.nametag_prefix}-eks-cluster-node-group-general"
  node_role_arn   = aws_iam_role.eksworkerrole.arn
  subnet_ids      = aws_subnet.private_subents[*].id

  capacity_type  = "ON_DEMAND"
  disk_size      = var.eks_worker_node_group_disk_size
  ami_type       = "AL2_x86_64"
  instance_types = [var.eks_worker_node_group_instance_type]

  scaling_config {
    desired_size = var.node_group_desired_size
    max_size     = var.node_group_max_size
    min_size     = var.node_group_min_size
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.workerrole_policy_attachment
  ]

  tags = merge(var.common_tags, { "Name" : "${local.nametag_prefix}-eks-node-group-general-purpose-nodes" })

}

