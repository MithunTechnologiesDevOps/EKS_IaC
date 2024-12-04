output "cluster_name" {
  value = aws_eks_cluster.main.name
}

output "cluster_api_endpoint" {
  value = aws_eks_cluster.main.endpoint
}