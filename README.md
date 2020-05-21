# Launch an EKS Self-Managed Node Group

This terraform module will deploy the following services:
- IAM Instance Profile
- IAM Role
- IAM Role Policy
- Security Group
- Launch Template
- Auto Scaling Group

# Usage Instructions:
## Variables
| Parameter            | Type    | Description                                                                                              | Default    | Required |
|----------------------|---------|----------------------------------------------------------------------------------------------------------|------------|----------|
| cluster_name     | string  | Name of EKS cluster   |            | Y        |
| desired_size         | number  | Initial number of nodes to launch               | 2          | N        |
| max_size             | number  | Maximum number of nodes                                                                                  | 4          | N        |
| min_size             | number  | Minimum number of nodes to maintain at any given point of time                                           | 2          | N        |
| instance_type        | string  | Type of instance to be used for EKS nodes                                                                | t3.medium  | N        |
| ami_id             | string  | Leave it blank to use latest eks optmised image maintained by AWS or provide your own image id            |  | N        |
| volume_size            | number  | Size of each EBS volume attached to EKS node                                                             | 20         | N        |
| encrypt_volume            | boolean  | Whether to apply rest side encryption on ebs volume                    | true         | N        |
| volume_type | string | EBS volume type to used. Valid values: gp2 or io1                     | true      | N        |
| iops | number | No. of iops for EBS volume. **Required if volume_type is set to io1**             | 0      | N        |
| kms_key         | string  | ID/Alias/ARN of kms key to use for encrypting ebs volume     | alias/aws/ebs           | N        |
| ssh_key_name        | string    | Name of key pair to used for remote access of nodes               |            | N        |
| ssh_cidr_blocks     | list    | CIDR blocks to whitelist for remote access of nodes. **Either of ssh_cidr_blocks or ssh_source_sg_id is required**                   | ["0.0.0.0/0"]           | N        |
| ssh_source_sg_id           | string    | Security group to whitelist for remote access of nodes. **Either of ssh_cidr_blocks or ssh_source_sg_id is required**       |            | N        |
| bootstrap_args           | string    | Bootstrap arguments to supply to eks bootstrap script                           |            | N        |
| user_data_base64           | string    | Additional user data in base64 format to execute when instance boots up                              |            | N        |
| subnet_ids           | list    | List of subnet ids to be used for launching EKS nodes                                                    |            | Y        |

## Outputs
| Parameter           | Type   | Description               |
|---------------------|--------|---------------------------|
| profile           | string | Name of IAM instance profile created for EKS nodes            |
| role_arn | string | ARN of IAM role created for EKS nodes       |
| cluster_name           | string | Name of EKS cluster to which nodes are attached            |
| sg_ids           | list | IDs of security group attached to EKS node            |
| asg_id           | string | ID of autoscaling group            |

## Deployment
- `terraform init` - download plugins required to deploy resources
- `terraform plan` - get detailed view of resources that will be created, deleted or replaced
- `terraform apply -auto-approve` - deploy the template without confirmation (non-interactive mode)
- `terraform destroy -auto-approve` - terminate all the resources created using this template without confirmation (non-interactive mode)

## [IMPORTANT] Post Steps (Source: [AWS](https://docs.aws.amazon.com/eks/latest/userguide/launch-workers.html#self-managed-nodes))
Once the self managed nodes are created you need to execute the following steps so that your nodes can join EKS cluster.

#### Download AWS IAM Authenticator configuration map:
```
curl -o aws-auth-cm.yaml https://amazon-eks.s3.us-west-2.amazonaws.com/cloudformation/2020-05-08/aws-auth-cm.yaml
```

#### Open the file with your favorite text editor. Replace the <ARN of instance role (not instance profile)> snippet with the `role_arn` value from terraform output:
**Note:** Do not modify any other lines in this file.
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: <ARN of instance role (not instance profile)>
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
```

#### Apply the configuration. This command may take a few minutes to finish
```
kubectl apply -f aws-auth-cm.yaml
```

#### Watch the status of nodes
```
kubectl get nodes --watch
```