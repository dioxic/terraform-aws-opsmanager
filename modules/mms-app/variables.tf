variable "aws_key_name" {
  description = "AWS SSH key name"
  type        = string
  default     = null
}

variable "ssh_authorized_key" {
  description = "SSH authorized key (added to aws key pair)"
  type        = string
  default     = ""
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

variable "web_ingress_cidr" {
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
  default     = "t3.large"
}

variable "mms_rpm" {
  description = "Ops Manager RPM name"
  default     = "mongodb-mms-4.4.5.103.20201104T1729Z-1.x86_64.rpm"
}

variable "agent_rpm" {
  description = "Ops Manager Agent RPM name"
  default     = "mongodb-mms-automation-agent-manager-10.14.16.6437-1.x86_64.rhel7.rpm"
}

variable "mms_repo" {
  description = "URL for Ops Manager binaries"
  default     = "https://downloads.mongodb.com/on-prem-mms/rpm/"
}

variable "create_nlb" {
  description = "Create a network load balancer for Ops Manager"
  type        = bool
  default     = false
}

variable "enable_https" {
  type    = bool
  default = true
}

variable "zone_id" {
  type    = string
  default = null
}

variable "zone_name" {
  type    = string
  default = null
}

variable "ca_private_key_pem" {}

variable "ca_cert_pem" {}

variable "appdb_mongo_uri" {
  description = "Mongo URI for the appdb"
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

variable "mongo_shell_version" {
  description = "MongoDB version for the shell"
  default     = "4.4"
}

variable "mms_prefix" {
  description = "Name prefix for mms nodes"
  default     = "mms"
}