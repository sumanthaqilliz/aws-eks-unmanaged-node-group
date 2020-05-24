variable "cluster_name" {}

variable "ng_name" {
  default = ""
}

variable "desired_size" {
  default = 2
}

variable "max_size" {
  default = 4
}

variable "min_size" {
  default = 2
}

variable "instance_type" {
  default = "t3.medium"
}

variable "ami_id" {
  default = ""
}

variable "volume_size" {
  default = 20
}

variable "encrypt_volume" {
  default = true
}

variable "volume_type" {
  default = "gp2"
}

variable "iops" {
  default = 0
}

variable "kms_key" {
  default = "alias/aws/ebs"
}

variable "ssh_key_name" {
  default = ""
}

variable "ssh_cidr_blocks" {
  type = list

  default = ["0.0.0.0/0"]
}

variable "ssh_source_sg_id" {
  default = ""
}

variable "bootstrap_args" {
  default = ""
}

variable "user_data_base64" {
  default = ""
}

variable "subnet_ids" {
  type = list
}
