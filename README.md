# Launch Self-Managed Node Group for EKS Cluster

![License](https://img.shields.io/github/license/terrablocks/aws-eks-unmanaged-node-group?style=for-the-badge) ![Tests](https://img.shields.io/github/workflow/status/terrablocks/aws-eks-unmanaged-node-group/tests/main?label=Test&style=for-the-badge) ![Checkov](https://img.shields.io/github/workflow/status/terrablocks/aws-eks-unmanaged-node-group/checkov/main?label=Checkov&style=for-the-badge) ![Commit](https://img.shields.io/github/last-commit/terrablocks/aws-eks-unmanaged-node-group?style=for-the-badge) ![Release](https://img.shields.io/github/v/release/terrablocks/aws-eks-unmanaged-node-group?style=for-the-badge)

This terraform module will deploy the following services:
- IAM Instance Profile
- IAM Role
- IAM Role Policy
- Security Group
- Launch Template
- Auto Scaling Group

# Usage Instructions
## Example
```terraform
module "eks_worker" {
  source = "github.com/terrablocks/aws-eks-unmanaged-node-group.git"

  cluster_name = "eks-cluster"
  subnet_ids   = ["subnet-xxxx", "subnet-yyyy"]
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13 |
| aws | >= 3.37.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster_name | Name of EKS cluster | `string` | n/a | yes |
| ng_name | Name used for launch template and autoscaling group created for EKS nodes | `string` | `""` | no |
| desired_size | Initial number of nodes to launch | `number` | `2` | no |
| max_size | Maximum number of nodes | `number` | `4` | no |
| min_size | Minimum number of nodes to maintain at any given point of time | `number` | `2` | no |
| instance_type | Type of instance to be used for EKS nodes | `string` | `"t3.medium"` | no |
| ami_id | Leave it blank to use latest eks optmised image maintained by AWS or provide your own image id | `string` | `""` | no |
| volume_size | Size of each EBS volume attached to EKS node | `number` | `30` | no |
| encrypt_volume | Whether to apply rest side encryption on ebs volume | `bool` | `true` | no |
| volume_type | EBS volume type to used. Valid values: gp2, gp3, io1 or io2 | `string` | `"gp2"` | no |
| iops | Number of iops for EBS volume. **Required if `volume_type` is set to io1** | `number` | `0` | no |
| kms_key | ID/Alias/ARN of kms key to use for encrypting ebs volume | `string` | `"alias/aws/ebs"` | no |
| ng_sg_ids | Security group id to attach to node group. Leave it blank to create new security group | `list(string)` | `[]` | no |
| create_node_iam_profile | Whether to create new IAM instance profile for EKS nodes | `bool` | `true` | no |
| node_iam_profile | IAM instance profile to associate with EC2. Leave it blank to create new instance profile with required permissions | `string` | `""` | no |
| ssh_key_name | Name of key pair to used for remote access of nodes | `string` | `""` | no |
| ssh_cidr_blocks | CIDR blocks to whitelist for remote access of nodes. **Either of ssh_cidr_blocks or ssh_source_sg_id is required** | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| ssh_source_sg_id | Security group to whitelist for remote access of nodes. **Either of ssh_cidr_blocks or ssh_source_sg_id is required** | `string` | `""` | no |
| bootstrap_args | Bootstrap arguments to supply to eks bootstrap script | `string` | `""` | no |
| user_data_base64 | Additional user data in base64 format to execute when instance boots up | `string` | `""` | no |
| subnet_ids | List of subnet ids to be used for launching EKS nodes | `list(string)` | n/a | yes |
| use_spot_instances | Use spot instance for EKS nodes | `bool` | `false` | no |
| spot_max_price | Maximum price you would like to pay for spot instances | `number` | `0` | no |
| spot_interruption_behavior | What should happen to instance when interrupted. Valid values: hibernate, stop or terminate | `string` | `""` | no |
| spot_type | The Spot Instance request type. Valid values: one-time, or persistent | `string` | `""` | no |
| spot_block_duration_minutes | Number of minutes to wait before interrupting a Spot Instance after it is launched. Must be between 60 & 360 and multiple of 60 | `number` | `0` | no |
| spot_expiry | The end date of the request | `string` | `""` | no |
| tags | A map of key and value pair to assign to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| iam_profile | Name of IAM instance profile associated with EKS nodes |
| role_name | Name of IAM role associated with EKS nodes |
| role_arn | ARN of IAM role associated with EKS nodes |
| cluster_name | Name of EKS cluster to which nodes are attached |
| sg_ids | IDs of security group attached to EKS node |
| asg_id | ID of autoscaling group |

## [IMPORTANT] Post Steps (Source: [AWS](https://docs.aws.amazon.com/eks/latest/userguide/launch-workers.html#self-managed-nodes))
Once the self managed nodes are created you need to execute the following steps so that your nodes can join EKS cluster.

#### Download AWS IAM Authenticator configuration map:
```
curl -o aws-auth-cm.yaml https://amazon-eks.s3.us-west-2.amazonaws.com/cloudformation/2020-05-08/aws-auth-cm.yaml
```

#### Open the file with your favorite text editor. Replace the <ARN of instance role (**NOT instance profile**)> snippet with the `role_arn` value from terraform output:
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

## Cluster Autoscaler Setup (Source: [AWS](https://docs.aws.amazon.com/eks/latest/userguide/cluster-autoscaler.html#ca-deploy))
To enable Cluster Autoscaler execute the following steps:

#### Deploy Cluster Autoscaler:
```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/autoscaler/master/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml
```

#### Add annotation to `cluster-autoscaler` deployment:
```
kubectl -n kube-system annotate deployment.apps/cluster-autoscaler cluster-autoscaler.kubernetes.io/safe-to-evict="false"
```

#### Edit `custer-autoscaler` deployment and do the required changes:
```
kubectl -n kube-system edit deployment.apps/cluster-autoscaler
```

Replace `<YOUR CLUSTER NAME>` with your cluster's name, and add the following options:
- --balance-similar-node-groups
- --skip-nodes-with-system-pods=false

Example:
```
spec:
  containers:
  - command:
    - ./cluster-autoscaler
    - --v=4
    - --stderrthreshold=info
    - --cloud-provider=aws
    - --skip-nodes-with-local-storage=false
    - --expander=least-waste
    - --node-group-auto-discovery=asg:tag=k8s.io/cluster-autoscaler/enabled,k8s.io/cluster-autoscaler/<YOUR CLUSTER NAME>
    - --balance-similar-node-groups
    - --skip-nodes-with-system-pods=false
```

#### Set image for `cluster-autoscaler` deployment:

- Visit Cluster Autoscaler [releases](https://github.com/kubernetes/autoscaler/releases) to get the latest semantic version number for your kubernetes version. Eg: If your k8s version is 1.16, look for the latest release of cluster-autoscaler beginning with your k8s version and note down the semantic version (1.16.`x`)
- You can replace `us` with `asia` or `eu` as per proximity

```
kubectl -n kube-system set image deployment.apps/cluster-autoscaler cluster-autoscaler=k8s.gcr.io/autoscaling/cluster-autoscaler:v1.x.x
```

#### Verify Cluster Autoscaler deployment by checking logs:
```
kubectl -n kube-system logs -f deployment.apps/cluster-autoscaler
```
