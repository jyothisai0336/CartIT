# ─── CartIt Production Environment ─────────────────────────────────────────────
terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = { source = "hashicorp/aws"; version = "~> 5.0" }
  }
  backend "s3" {
    bucket         = "cartit-terraform-state-prod"   # update with your account ID
    key            = "prod/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "cartit-terraform-locks"
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Project     = "cartit"
      Environment = "prod"
      ManagedBy   = "terraform"
      Owner       = "devops-team"
    }
  }
}

locals {
  project = "cartit"
  env     = "prod"
  azs     = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"]
  tags    = { Project = "cartit"; Environment = "prod"; ManagedBy = "terraform" }
}

# ── VPC ────────────────────────────────────────────────────────────────────────
module "vpc" {
  source             = "../../modules/vpc"
  project            = local.project
  env                = local.env
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = local.azs
  tags               = local.tags
}

# ── ECR ────────────────────────────────────────────────────────────────────────
module "ecr" {
  source  = "../../modules/ecr"
  project = local.project
  tags    = local.tags
}

# ── EKS ────────────────────────────────────────────────────────────────────────
module "eks" {
  source              = "../../modules/eks"
  project             = local.project
  env                 = local.env
  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids
  kubernetes_version  = "1.29"
  node_instance_types = ["m5.xlarge"]
  node_desired        = 3
  node_min            = 3
  node_max            = 20
  spot_desired        = 2
  spot_max            = 20
  tags                = local.tags
}

# ── BASTION HOST ───────────────────────────────────────────────────────────────
module "bastion" {
  source             = "../../modules/bastion"
  project            = local.project
  env                = local.env
  vpc_id             = module.vpc.vpc_id
  public_subnet_id   = module.vpc.public_subnet_ids[0]
  bastion_public_key = var.bastion_public_key
  allowed_ssh_cidrs  = var.allowed_ssh_cidrs   # your office/home IP
  tags               = local.tags
}

# ── JENKINS EC2 ────────────────────────────────────────────────────────────────
module "jenkins" {
  source              = "../../modules/jenkins"
  project             = local.project
  env                 = local.env
  vpc_id              = module.vpc.vpc_id
  vpc_cidr            = "10.0.0.0/16"
  private_subnet_id   = module.vpc.private_subnet_ids[0]
  bastion_sg_id       = module.bastion.bastion_sg_id
  eks_cluster_name    = module.eks.cluster_name
  kms_key_arn         = module.eks.kms_key_arn
  aws_region          = var.aws_region
  instance_type       = "t3.medium"
  jenkins_public_key  = var.jenkins_public_key
  allowed_cidr_blocks = ["10.0.0.0/16"]        # only from within VPC
  tags                = local.tags
}

# ── SONARQUBE EC2 ──────────────────────────────────────────────────────────────
module "sonarqube" {
  source               = "../../modules/sonarqube"
  project              = local.project
  env                  = local.env
  vpc_id               = module.vpc.vpc_id
  private_subnet_id    = module.vpc.private_subnet_ids[1]
  bastion_sg_id        = module.bastion.bastion_sg_id
  jenkins_sg_id        = module.jenkins.jenkins_sg_id
  kms_key_arn          = module.eks.kms_key_arn
  aws_region           = var.aws_region
  instance_type        = "t3.medium"
  sonarqube_public_key = var.sonarqube_public_key
  tags                 = local.tags
}

data "aws_caller_identity" "current" {}
