variable "aws_key_name" {
  description = "AWS SSH key name"
}

variable "tags" {
  description = "Optional map of tags to set on resources, defaults to empty map."
  type        = map(string)
  default     = {}
}

variable "name" {
}

variable "ami_owner" {
  default = "amazon"
}

variable "ami_name" {
  default = "amzn2-ami-hvm-*-x86_64-gp2"
}

variable "mms_rpm" {
  description = "Ops Manager RPM name"
  default     = "mongodb-mms-4.4.5.103.20201104T1729Z-1.x86_64.rpm"
}

variable "agent_rpm" {
  description = "Ops Manager Agent RPM name"
  default     = "mongodb-mms-automation-agent-manager-10.14.16.6437-1.x86_64.rhel7.rpm"
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

variable "s3_config_bucket" {

}

variable "zone_id" {}

variable "zone_name" {}

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