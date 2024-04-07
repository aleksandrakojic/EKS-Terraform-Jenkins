# configure aws provider
provider "aws" {
  region  = var.region
}

# configure backend
terraform {
  backend "s3" {
    bucket         = "ehop-bucket"
    key            = "eks/terraform.tfstate"
    region         = "eu-west-3"
  }
}
