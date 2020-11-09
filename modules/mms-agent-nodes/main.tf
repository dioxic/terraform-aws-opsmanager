locals {
  instances           = { for i in range(var.instance_count) : "${var.name}-${var.name_prefix}${i}" =>  {
    idx  = i
    fqdn = "${var.name_prefix}${i}.${var.name}.${var.zone_name}"
  }}

  fqdns = values(local.instances)[*]["fqdn"]

}

data "template_cloudinit_config" "config" {
  for_each = local.instances

  base64_encode = true
  gzip = true

  part {
    content_type = "text/cloud-config"
    content  = templatefile("${path.module}/templates/cloud-init.yaml", {
      data_block_device   = var.data_block_device_name
      mount_point         = var.data_block_device_mount_point
      mongodb_nproc       = base64encode(file("${path.module}/scripts/99-mongodb-nproc.conf"))
      disable_thp_service = base64encode(file("${path.module}/scripts/disable-thp.service"))
      server_cert_url     = "https://${aws_s3_bucket_object.server_cert[each.key].bucket}.s3.amazonaws.com/${aws_s3_bucket_object.server_cert[each.key].key}"
      client_cert_url     = "https://${aws_s3_bucket_object.client_cert[each.key].bucket}.s3.amazonaws.com/${aws_s3_bucket_object.client_cert[each.key].key}"
      ca_cert_url         = "https://${aws_s3_bucket_object.ca_cert.bucket}.s3.amazonaws.com/${aws_s3_bucket_object.ca_cert.key}"
      fqdn                = each.value["fqdn"]
      authorized_key      = trimspace(var.ssh_authorized_key)
      readahead_service   = base64encode(templatefile("${path.module}/templates/readahead.service", {
        data_block_device  = var.data_block_device_name
      }))
    })
  }
}

resource "aws_s3_bucket_object" "ca_cert" {
  bucket = var.s3_config_bucket
  key    = "ca.pem"
  acl    = "public-read"
  content = var.ca_cert_pem
}

resource "aws_s3_bucket_object" "client_cert" {
  for_each = local.instances

  bucket = var.s3_config_bucket
  key    = "${each.value["fqdn"]}-client.pem"
  acl    = "public-read"
  content = module.client_cert[each.key].cert_pem
}

resource "aws_s3_bucket_object" "server_cert" {
  for_each = local.instances

  bucket = var.s3_config_bucket
  key    = "${each.value["fqdn"]}-server.pem"
  acl    = "public-read"
  content = module.server_cert[each.key].cert_pem
}

resource "aws_security_group" "main" {
  name_prefix = "${var.name}-nodes-sg-"
  vpc_id = var.vpc_id
  tags = var.tags
}

resource "aws_security_group_rule" "ssh" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  description = "SSH"
  cidr_blocks = var.ssh_ingress_cidr
  security_group_id = aws_security_group.main.id
}

resource "aws_security_group_rule" "mongo" {
  type = "ingress"
  from_port = 27000
  to_port = 30000
  protocol = "tcp"
  description = "mongo"
  cidr_blocks = var.mongo_ingress_cidr
  security_group_id = aws_security_group.main.id
}

resource "aws_security_group_rule" "self" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  description = "self"
  self = true
  security_group_id = aws_security_group.main.id
}

resource "aws_security_group_rule" "egress" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.main.id
}

module "server_cert" {
  for_each = local.instances
  source   = "../tls-certs"

  ca_cert_pem         = var.ca_cert_pem
  ca_private_key_pem  = var.ca_private_key_pem
  organizational_unit = "cluster"
  common_name         = each.value["fqdn"]
  dns_names           = [each.value["fqdn"]]
  allowed_uses        = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth"
  ]
}

module "client_cert" {
  for_each = local.instances
  source   = "../tls-certs"

  ca_cert_pem         = var.ca_cert_pem
  ca_private_key_pem  = var.ca_private_key_pem
  organizational_unit = "mms"
  common_name         = "automation-agent"
  allowed_uses        = [
    "key_encipherment",
    "digital_signature",
    "client_auth"
  ]
}

resource "aws_route53_record" "instance" {
  for_each = local.instances

  zone_id = var.zone_id
  name    = each.value["fqdn"]
  type    = "A"
  ttl     = "300"

  records = [ aws_instance.main[each.key].public_ip ]
}

resource "aws_instance" "main" {
  for_each = local.instances

  ami = var.ami_id
  instance_type = var.instance_type
  key_name = var.aws_key_name
  vpc_security_group_ids = [aws_security_group.main.id]
  subnet_id = sort(var.subnet_ids)[each.value["idx"] % length(var.subnet_ids)]

  root_block_device {
    volume_type = "gp2"
    volume_size = 20
  }

  ebs_block_device {
    device_name = "/dev/${var.data_block_device_name}"
    volume_type = var.data_block_device_type
    volume_size = var.data_block_device_size
    iops        = var.data_block_device_iops
  }

  tags = merge(
  {
    "Name" = each.key
  },
  var.tags
  )

  user_data = data.template_cloudinit_config.config[each.key].rendered

}
