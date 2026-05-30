variable "aws_region"            { type = string; default = "ap-south-1" }
variable "db_username"           { type = string; sensitive = true }
variable "db_password"           { type = string; sensitive = true }
variable "redis_auth_token"      { type = string; sensitive = true }
variable "bastion_public_key"    { type = string; description = "SSH public key for Bastion" }
variable "jenkins_public_key"    { type = string; description = "SSH public key for Jenkins" }
variable "sonarqube_public_key"  { type = string; description = "SSH public key for SonarQube" }
variable "allowed_ssh_cidrs"     { type = list(string); description = "Your IP for SSH — e.g. [\"your.ip.address/32\"]" }
variable "acm_certificate_arn"   { type = string; default = "" }
