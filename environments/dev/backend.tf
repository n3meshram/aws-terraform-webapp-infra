terraform {
  backend "s3" {
    bucket         = "webapp-terraform-state-n3meshram"
    key            = "dev/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "webapp-terraform-lock"
    encrypt        = true
  }
}