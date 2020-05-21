output "profile" {
  value = aws_iam_instance_profile.eks_ng_vm_profile.name
}

output "role_arn" {
  value = aws_iam_role.eks_ng_role.arn
}

output "sg_id" {
  value = aws_security_group.eks_ng_sg.id
}

output "asg_id" {
  value = aws_autoscaling_group.eks_ng_asg.id
}

output "cluster_name" {
  value = var.cluster_name
}
