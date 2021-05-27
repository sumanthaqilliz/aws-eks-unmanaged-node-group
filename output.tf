output "iam_profile" {
  value       = local.node_iam_profile
  description = "Name of IAM instance profile associated with EKS nodes"
}

output "role_name" {
  value       = local.node_role_name
  description = "Name of IAM role associated with EKS nodes"
}

output "role_arn" {
  value       = local.node_role_arn
  description = "ARN of IAM role associated with EKS nodes"
}

output "cluster_name" {
  value       = var.cluster_name
  description = "Name of EKS cluster to which nodes are attached"
}

output "sg_ids" {
  value       = local.node_sg_ids
  description = "IDs of security group attached to EKS node"
}

output "asg_id" {
  value       = aws_autoscaling_group.eks_ng_asg.id
  description = "ID of autoscaling group"
}
