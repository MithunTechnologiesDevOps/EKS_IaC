terraform {
  backend "s3" {
    bucket = "mithuntech-terraform-statefiles-bucket"
    region = "ap-south-1"
    dynamodb_table = "mithuntech-terraform-statelock"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.0"
    }
  }
}