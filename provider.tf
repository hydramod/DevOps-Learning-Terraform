terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "6.18.0"
        }
    }
    backend "s3" {
      bucket = "terraform-state-test-ali"
      key = "terraform.tfstate"
      region = "us-east-1"
    }
}

provider "aws" {
    region = "us-east-1"
}

