# configure aws provider
provider "aws" {
  region  = var.region
}

# configure backend
terraform {
  backend "s3" {
    bucket         = "terraform"
    key            = "eks.terraform.tfstate"
    region         = "eu-west-3"
    dynamodb_table = "terraform-state-lock-dynamodb"
  }
}
