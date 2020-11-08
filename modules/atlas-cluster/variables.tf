variable "project_id" {
  description = "Atlas project id"
}

variable "cluster_name" {}

variable "atlas_private_key" {}

variable "atlas_public_key" {}

variable "cluster_region" {
  description = "Cluster deployment region"
}

variable "cluster_instance" {
  description = "Atlas cluster instance type (default: \"M10\")"
  default     = "M10"
}

variable "cluster_disk_size" {
  description = "Cluster disk size in GB (default: 10)"
  type        = number
  default     = 10
}

variable "cluster_mongo_version" {
  description = "Major MongoDB version for cluster (default \"4.4\")"
  default     = "4.4"
}

variable "create_admin_user" {
  description = "Create an atlasAdmin user in the project"
  type        = bool
  default     = false
}

variable "admin_user_name" {
  description = "Admin user name (default \"root\")"
  default     = "root"
}