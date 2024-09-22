provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

terraform {
  backend "s3" {
    bucket         = "devops-tf-task2-bucket"
    dynamodb_table = "state-lock"
    key            = "dev/statefile/terraform.tfstate" # Path in S3
    region         = "us-east-1"
    encrypt        = true
  }
}
