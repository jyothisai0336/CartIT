terraform {
  required_version = ">= 1.6.0"
  required_providers { aws = { source = "hashicorp/aws"; version = "~> 5.0" } }
  backend "s3" { bucket = "cartit-terraform-state-dev"; key = "dev/terraform.tfstate"; region = "ap-south-1"; encrypt = true; dynamodb_table = "cartit-terraform-locks" }
}
provider "aws" { region = "ap-south-1" }
locals { project="cartit"; env="dev"; azs=["ap-south-1a","ap-south-1b"] }
module "vpc" { source="../../modules/vpc"; project=local.project; env=local.env; vpc_cidr="10.1.0.0/16"; availability_zones=local.azs }
module "ecr" { source="../../modules/ecr"; project=local.project }
module "eks" { source="../../modules/eks"; project=local.project; env=local.env; vpc_id=module.vpc.vpc_id; private_subnet_ids=module.vpc.private_subnet_ids; node_instance_types=["t3.medium"]; node_desired=2; node_min=1; node_max=5; spot_desired=1; spot_max=5 }
