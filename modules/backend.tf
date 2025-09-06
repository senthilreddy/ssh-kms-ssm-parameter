terraform {
  backend "s3" {
    bucket         = "client-a-tfstate"
    key            = "client-a-tfstate/module-terraform.tfstate" 
    region         = "ap-south-1"
    encrypt        = true
  }
}