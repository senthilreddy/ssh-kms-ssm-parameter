terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket"
    key            = "client-a/terraform.tfstate"  # Path in the bucket
    region         = "ap-south-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}