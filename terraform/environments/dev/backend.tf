terraform {
  backend "s3" {
    bucket = "kdsingh-terraform-state"
    key    = "ai-platform-on-aws/dev/terraform.tfstate"
    region = "ap-south-1"
    ##   dynamodb_table = "terraform-state-lock"
    ##   encrypt        = true
  }
}
