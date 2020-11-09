variable "aws_key_name" {
  description = "AWS SSH key name"
  type        = string
}

variable "tags" {
  description = "Optional map of tags to set on resources, defaults to empty map."
  type        = map(string)
}

variable "name" {
  description = "Deployment name"
}

variable "ami_id" {}

variable "vpc_id" {}

variable "subnet_ids" {}

variable "ssh_ingress_cidr" {
  description = "list of CIDR addresses to whitelist for SSH"
  type = list(string)
  default = ["0.0.0.0/0"]
}

variable "mongo_ingress_cidr" {
  description = "list of CIDR addresses to whitelist for web"
  type = list(string)
  default = ["0.0.0.0/0"]
}

variable "instance_count" {
  description = "number of instances to create"
  default     = 1
}

variable "instance_type" {
  description = "instance type"
  default     = "t3.micro"
}

variable "zone_id" {}

variable "zone_name" {}

variable "ca_private_key_pem" {}

variable "ca_cert_pem" {}

variable "s3_config_bucket" {}

variable "agent_url" {
  description = "Full URL to download agent binaries"
}

variable "data_block_device_name" {
  description = "Block device name for data volume, default \"xvdb\""
  default     = "xvdb"
}

variable "data_block_device_mount_point" {
  description = "MongoDB data mount point, default \"/data\""
  default     = "/data"
}

variable "data_block_device_size" {
  description = "Size of the data volume"
  default     = 20
}

variable "data_block_device_type" {
  description = "Volume type of the data volume"
  default     = "gp2"
}

variable "data_block_device_iops" {
  description = "Provisioned IOPS for the data volume"
  default     = null
  type        = number
}

variable "name_prefix" {
  description = "Name prefix for mongo nodes"
  default     = "mongo"
}