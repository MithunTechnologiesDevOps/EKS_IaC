variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "vpc_cidr" {
  type    = string
  default = "192.168.0.0/16"
}

variable "enabledns_hostnames" {
  type    = bool
  default = true
}

variable "project" {
  type    = string
  default = "MithunTech"
}

variable "enviroment" {
  type    = string
  default = "dev"
}

variable "common_tags" {
  type = map(string)
  default = {
    "Company"   = "Mithun Technolgoies"
    "Manager"   = "Asish"
    "ManagedBy" = "Terraform"
  }
}

variable "aws_azs_list" {
  type    = list(string)
  default = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
}

variable "public_subents_cidrs" {
  type    = list(string)
  default = ["192.168.0.0/20", "192.168.16.0/20", "192.168.32.0/20"]
}

variable "private_subents_cidrs" {
  type    = list(string)
  default = ["192.168.48.0/20", "192.168.64.0/20", "192.168.80.0/20"]
}

variable "eks_worker_role_policy_arns" {
  type = list(string)
  default = ["arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy", "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  , "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly", "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"]
}

variable "eks_worker_node_group_disk_size" {
  type    = number
  default = 30
}
variable "eks_worker_node_group_instance_type" {
  type    = string
  default = "t2.large"
}

variable "node_group_desired_size" {
  type    = number
  default = 1
}
variable "node_group_min_size" {
  type    = number
  default = 1
}
variable "node_group_max_size" {
  type    = number
  default = 5
}