variable "project"            { type = string }
variable "env"                { type = string }
variable "vpc_id"             { type = string }
variable "public_subnet_id"   { type = string }
variable "bastion_public_key" { type = string }
variable "allowed_ssh_cidrs"  { type = list(string); description = "Your office/home IP" }
variable "tags"               { type = map(string); default = {} }
