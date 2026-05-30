variable "project"             { type = string }
variable "env"                 { type = string }
variable "vpc_id"              { type = string }
variable "private_subnet_ids"  { type = list(string) }
variable "kubernetes_version"  { type = string; default = "1.29" }
variable "node_instance_types" { type = list(string); default = ["t3.large"] }
variable "node_desired"        { type = number; default = 3 }
variable "node_min"            { type = number; default = 2 }
variable "node_max"            { type = number; default = 10 }
variable "spot_desired"        { type = number; default = 2 }
variable "spot_max"            { type = number; default = 20 }
variable "tags"                { type = map(string); default = {} }
