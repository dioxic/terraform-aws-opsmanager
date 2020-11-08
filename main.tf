provider "aws" {
  region = "eu-west-1"
}

provider "mongodbatlas" {
  public_key = var.atlas_public_key
  private_key = var.atlas_private_key
}

data "aws_region" "current" {}

data "aws_ami" "base" {
  most_recent = true
  owners = [var.ami_owner]

  filter {
    name = "name"
    values = [var.ami_name]
  }

  filter {
    name = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
  filter {
    name = "default-for-az"
    values = ["true"]
  }
}

data "aws_route53_zone" "mdbtraining" {
  name         = "mdbtraining.net."
  private_zone = false
}

//data "http" "my_public_ip" {
//  url = "https://api.ipify.org?format=json"
//  request_headers = {
//    Accept = "application/json"
//  }
//}

locals {
//  ifconfig = jsondecode(data.http.my_public_ip.body)

  appdb_mongo_uri_type          = split("://", module.appdb.srv_address)[0]
  appdb_mongo_uri_content       = split("://", module.appdb.srv_address)[1]
  appdb_mongo_uri_with_password = join("", [
    local.appdb_mongo_uri_type, "://",
    urlencode(module.appdb.admin_user_name), ":", urlencode(module.appdb.admin_user_password),
    "@", local.appdb_mongo_uri_content
  ])
}

resource "mongodbatlas_project_ip_access_list" "webapp" {
  count = length(module.webapp.public_ip)

  project_id = var.atlas_project_id
  ip_address = module.webapp.public_ip[count.index]
  comment    = "Managed by Terraform"
}

module "appdb" {
  source = "./modules/atlas-cluster"

  atlas_private_key = var.atlas_private_key
  atlas_public_key  = var.atlas_public_key
  cluster_instance  = "M10"
  cluster_name      = "appdb"
  cluster_region    = data.aws_region.current.name
  project_id        = var.atlas_project_id
  admin_user_name   = "opsMgr"
  create_admin_user = true
}

module "webapp" {
  source = "./modules/mms-app"

  ami_id                  = data.aws_ami.base.id
  name                    = var.name
  subnet_ids              = data.aws_subnet_ids.default.ids
  vpc_id                  = data.aws_vpc.default.id
  instance_count          = var.webapp_instance_count
  instance_type           = var.webapp_instance_type
  mongo_shell_version     = var.mongo_shell_version
  data_block_device_size  = var.webapp_data_block_device_size
  aws_key_name            = var.aws_key_name
  appdb_mongo_uri         = local.appdb_mongo_uri_with_password

  ca_cert_pem             = file("${path.module}/certs/ca.crt")
  ca_private_key_pem      = file("${path.module}/certs/ca.key")
  enable_https            = true
  create_nlb              = false

  zone_id                 = data.aws_route53_zone.mdbtraining.zone_id
  zone_name               = data.aws_route53_zone.mdbtraining.name

  tags                    = var.tags

}

module "nodes" {
  source = "./modules/mms-agent-nodes"

  ami_id                  = data.aws_ami.base.id
  name                    = var.name
  subnet_ids              = data.aws_subnet_ids.default.ids
  vpc_id                  = data.aws_vpc.default.id
  instance_count          = var.node_instance_count
  instance_type           = var.node_instance_type
  data_block_device_size  = var.node_data_block_device_size
  aws_key_name            = var.aws_key_name

  ca_cert_pem             = file("${path.module}/certs/ca.crt")
  ca_private_key_pem      = file("${path.module}/certs/ca.key")

  zone_id                 = data.aws_route53_zone.mdbtraining.zone_id
  zone_name               = data.aws_route53_zone.mdbtraining.name

  tags                    = var.tags
}