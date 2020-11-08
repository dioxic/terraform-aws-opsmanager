variable "tags" {
  description = "Optional map of tags to set on resources, defaults to empty map."
  type        = map(string)
}

variable "name" {
  description = "Deployment name"
}

variable "vpc_id" {}

variable "subnet_ids" {}

variable "ssh_ingress_cidr" {
  description = "list of CIDR addresses to whitelist for SSH"
  type = list(string)
  default = ["0.0.0.0/0"]
}

variable "web_ingress_cidr" {
  description = "list of CIDR addresses to whitelist for web"
  type = list(string)
  default = ["0.0.0.0/0"]
}

//variable "whitelist_ips" {
//  description = "Whitelist IPs for the project"
//  type        = list(string)
//  default     = []
//}