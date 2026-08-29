# PROVIDER

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.64"
    }
  }
  backend "s3" {
    bucket       = "tf-s3-grupo-abgr"
    key          = "terraform.tfstate"
    use_lockfile = true
    region       = "us-east-1"
  }
}
provider "aws" {
  region = "us-east-1"
}