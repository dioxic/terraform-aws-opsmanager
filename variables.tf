variable "aws_key_name" {
  description = "AWS SSH key name"
  default     = "markbm"
}

variable "tags" {
  description = "Optional map of tags to set on resources, defaults to empty map."
  type        = map(string)
  default     = {
	  owner = "mark.baker-munton"
  }
}

variable "name" {
  default = "markbm"
}

variable "ami_owner" {
  default = "amazon"
}

variable "ami_name" {
  default = "amzn2-ami-hvm-*-x86_64-gp2"
}

variable "node_instance_type" {
  description = "instance type"
  default     = "t3.micro"
}

variable "node_instance_count" {
  description = "Number of servers to provision for agent-controlled nodes"
  default     = 1
}

variable "node_data_block_device_size" {
  description = "Size of the data volume for nodes"
  default     = 20
}

variable "webapp_instance_type" {
  description = "instance type"
  default     = "t3.large"
}

variable "webapp_instance_count" {
  description = "Number of servers to provision for the Ops Manager application"
  default     = 1
}

variable "webapp_data_block_device_size" {
  description = "Size of the data volume"
  default     = 20
}

variable "mongo_shell_version" {
  description = "MongoDB version for the shell"
  default     = "4.4"
}

variable "atlas_private_key" {}

variable "atlas_public_key" {}

variable "atlas_project_id" {
  description = "Atlas project id"
}

//variable "whitelist_ips" {
//  description = "Whitelist IPs for the project"
//  type        = list(string)
//  default     = []
//}