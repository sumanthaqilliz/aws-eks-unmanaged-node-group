output "iam_profile" {
  value = local.node_iam_profile
}

output "role_name" {
  value = local.node_role_name
}

output "role_arn" {
  value = local.node_role_arn
}

output "sg_ids" {
  value = local.node_sg_ids
}

output "asg_id" {
  value = aws_autoscaling_group.eks_ng_asg.id
}

output "cluster_name" {
  value = var.cluster_name
}
