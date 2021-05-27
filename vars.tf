variable "cluster_name" {
  type        = string
  description = "Name of EKS cluster"
}

variable "ng_name" {
  type        = string
  default     = ""
  description = "Name used for launch template and autoscaling group created for EKS nodes"
}

variable "desired_size" {
  type        = number
  default     = 2
  description = "Initial number of nodes to launch"
}

variable "max_size" {
  type        = number
  default     = 4
  description = "Maximum number of nodes"
}

variable "min_size" {
  type        = number
  default     = 2
  description = "Minimum number of nodes to maintain at any given point of time"
}

variable "instance_type" {
  type        = string
  default     = "t3.medium"
  description = "Type of instance to be used for EKS nodes"
}

variable "ami_id" {
  type        = string
  default     = ""
  description = "Leave it blank to use latest eks optmised image maintained by AWS or provide your own image id"
}

variable "volume_size" {
  type        = number
  default     = 30
  description = "Size of each EBS volume attached to EKS node"
}

variable "encrypt_volume" {
  type        = bool
  default     = true
  description = "Whether to apply rest side encryption on ebs volume"
}

variable "volume_type" {
  type        = string
  default     = "gp2"
  description = "EBS volume type to used. Valid values: gp2, gp3, io1 or io2"
}

variable "iops" {
  type        = number
  default     = 0
  description = "Number of iops for EBS volume. **Required if `volume_type` is set to io1**"
}

variable "kms_key" {
  type        = string
  default     = "alias/aws/ebs"
  description = "ID/Alias/ARN of kms key to use for encrypting ebs volume"
}

variable "ng_sg_ids" {
  type        = list(string)
  default     = []
  description = "Security group id to attach to node group. Leave it blank to create new security group"
}

variable "create_node_iam_profile" {
  type        = bool
  default     = true
  description = "Whether to create new IAM instance profile for EKS nodes"
}

variable "node_iam_profile" {
  type        = string
  default     = ""
  description = "IAM instance profile to associate with EC2. Leave it blank to create new instance profile with required permissions"
}

variable "ssh_key_name" {
  type        = string
  default     = ""
  description = "Name of key pair to used for remote access of nodes"
}

variable "ssh_cidr_blocks" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "CIDR blocks to whitelist for remote access of nodes. **Either of ssh_cidr_blocks or ssh_source_sg_id is required**"
}

variable "ssh_source_sg_id" {
  type        = string
  default     = ""
  description = "Security group to whitelist for remote access of nodes. **Either of ssh_cidr_blocks or ssh_source_sg_id is required**"
}

variable "bootstrap_args" {
  type        = string
  default     = ""
  description = "Bootstrap arguments to supply to eks bootstrap script"
}

variable "user_data_base64" {
  type        = string
  default     = ""
  description = "Additional user data in base64 format to execute when instance boots up"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet ids to be used for launching EKS nodes"
}

variable "use_spot_instances" {
  type        = bool
  default     = false
  description = "Use spot instance for EKS nodes"
}

variable "spot_max_price" {
  type        = number
  default     = 0
  description = "Maximum price you would like to pay for spot instances"
}

variable "spot_interruption_behavior" {
  type        = string
  default     = ""
  description = "What should happen to instance when interrupted. Valid values: hibernate, stop or terminate"
}

variable "spot_type" {
  type        = string
  default     = ""
  description = "The Spot Instance request type. Valid values: one-time, or persistent"
}

variable "spot_block_duration_minutes" {
  type        = number
  default     = 0
  description = "Number of minutes to wait before interrupting a Spot Instance after it is launched. Must be between 60 & 360 and multiple of 60"
}

variable "spot_expiry" {
  type        = string
  default     = ""
  description = "The end date of the request"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A map of key and value pair to assign to resources"
}
