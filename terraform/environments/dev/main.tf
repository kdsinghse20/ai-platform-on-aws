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

module "security_groups" {

  source = "../../modules/security-groups"

  #  project_name = "ai-ollama"
  #  environment  = "dev"

  vpc_id = module.vpc.vpc_id

}

module "iam" {

  source = "../../modules/iam"

  project_name = "ai-ollama"
  environment  = "dev"

}

data "aws_ami" "ubuntu" {

  most_recent = true

  owners = ["099720109477"]

  filter {

    name = "name"

    values = [
      "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"
    ]

  }

}

module "openwebui" {

  source = "../../modules/ec2"

  project_name = "ai-ollama"

  environment = "dev"

  instance_name = "openwebui"

  ami_id = data.aws_ami.ubuntu.id

  instance_type = "t3.large"

  subnet_id = module.vpc.private_app_subnet_ids[0]

  security_group_ids = [
    module.security_groups.openwebui_security_group_id
  ]

  iam_instance_profile = module.iam.instance_profile_name

}

module "ollama" {

  source = "../../modules/ec2"

  project_name = "ai-ollama"

  environment = "dev"

  instance_name = "ollama"

  ami_id = data.aws_ami.ubuntu.id

  instance_type = "g4dn.xlarge"

  subnet_id = module.vpc.private_ai_subnet_ids[0]

  security_group_ids = [
    module.security_groups.ollama_security_group_id
  ]

  iam_instance_profile = module.iam.instance_profile_name

}



