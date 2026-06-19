module "vpc" {
  source = "../../modules/vpc"

  vpc_name = "ai-ollama"

  vpc_cidr = "10.0.0.0/16"

  public_subnet_cidrs = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]

  private_app_subnet_cidrs = [
    "10.0.10.0/24",
    "10.0.11.0/24"
  ]

  private_ai_subnet_cidrs = [
    "10.0.20.0/24",
    "10.0.21.0/24"
  ]
}
