terraform {
  backend "s3" {
    bucket         = "zero-touch-deployements-aws-terraform-docker"
    key            = "terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
