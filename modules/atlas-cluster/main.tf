provider "mongodbatlas" {
  public_key = var.atlas_public_key
  private_key = var.atlas_private_key
}

locals {
  atlasRegionName=upper(replace(var.cluster_region, "-", "_"))
}

resource "random_password" "password" {
  length = 16
  special = true
  override_special = "_%@"
}

resource "mongodbatlas_database_user" "root" {
  count = var.create_admin_user ? 1 : 0

  username           = var.admin_user_name
  password           = random_password.password.result
  project_id         = var.project_id
  auth_database_name = "admin"

  roles {
    role_name     = "atlasAdmin"
    database_name = "admin"
  }

  scopes {
    name   = mongodbatlas_cluster.main.name
    type = "CLUSTER"
  }
}

resource "mongodbatlas_cluster" "main" {
  project_id   = var.project_id
  name         = var.cluster_name
  cluster_type = "REPLICASET"

  replication_factor           = 3
  provider_backup_enabled      = false
  auto_scaling_disk_gb_enabled = true
  mongo_db_major_version       = var.cluster_mongo_version

  //Provider Settings "block"
  provider_name               = "AWS"
  disk_size_gb                = var.cluster_disk_size
  provider_volume_type        = "STANDARD"
  provider_encrypt_ebs_volume = true
  encryption_at_rest_provider = "NONE"
  provider_instance_size_name = var.cluster_instance
  provider_region_name        = local.atlasRegionName

  //advanced settings
  advanced_configuration {
    javascript_enabled                   = false
    minimum_enabled_tls_protocol         = "TLS1_2"
  }
}