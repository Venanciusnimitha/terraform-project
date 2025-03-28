#https://registry.terraform.io/providers/hashicorp/aws/latest/docs
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}
provider "aws" {
  shared_credentials_files = ["C:\\Users\\Kaliraja\\.aws\\credentials"]
  profile                  = "vscode"
  region                   = "us-west-2"
}