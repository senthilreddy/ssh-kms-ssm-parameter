terraform {
  backend "s3" {
    bucket         = "client-a-tfstate"
    key            = "client-a/infra-terraform.tfstate"  # Path in the bucket
    region         = "ap-south-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}