variable "project"            { type = string }
variable "env"                { type = string }
variable "vpc_id"             { type = string }
variable "vpc_cidr"           { type = string }
variable "private_subnet_id"  { type = string }
variable "bastion_sg_id"      { type = string }
variable "eks_cluster_name"   { type = string }
variable "kms_key_arn"        { type = string }
variable "aws_region"         { type = string; default = "ap-south-1" }
variable "instance_type"      { type = string; default = "t3.medium" }
variable "jenkins_public_key" { type = string }
variable "allowed_cidr_blocks"{ type = list(string); default = [] }
variable "tags"               { type = map(string); default = {} }
