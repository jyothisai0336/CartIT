variable "project"               { type = string }
variable "env"                   { type = string }
variable "vpc_id"                { type = string }
variable "private_subnet_id"     { type = string }
variable "bastion_sg_id"         { type = string }
variable "jenkins_sg_id"         { type = string }
variable "kms_key_arn"           { type = string }
variable "aws_region"            { type = string; default = "ap-south-1" }
variable "instance_type"         { type = string; default = "t3.medium" }
variable "sonarqube_public_key"  { type = string }
variable "tags"                  { type = map(string); default = {} }
