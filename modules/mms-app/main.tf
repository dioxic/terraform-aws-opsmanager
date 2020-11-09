locals {
  host_port           = var.enable_https ? 8443 : 8080
  nlb_port            = var.enable_https ? 443 : 80
  create_zone_record  = var.zone_id != null && var.zone_name != null
  zone_central_dns    = "${var.mms_prefix}.${var.name}.${var.zone_name}"

  protocol       = var.enable_https ? "https" : "http"
  port           = var.create_nlb ? local.nlb_port : local.host_port

  mms_central_dns     = local.create_zone_record ? local.zone_central_dns : var.create_nlb ? aws_lb.main[0].dns_name : "localhost"
  mms_central_url     = "${local.protocol}://${local.mms_central_dns}:${local.port}"

  instances           = { for i in range(var.instance_count) : "${var.name}-${var.mms_prefix}${i}" =>  {
    idx  = i
    fqdn = "${var.mms_prefix}${i}.${var.name}.${var.zone_name}"
  }}

}

data "template_cloudinit_config" "config" {
  for_each = local.instances

  base64_encode = true
  gzip = true
  part {
    content_type = "text/cloud-config"
    content  = templatefile("${path.module}/templates/cloud-init.yaml", {
      mongodb_package     = "mongodb-enterprise"
      mongodb_version     = var.mongo_shell_version
      repo_url            = "repo.mongodb.com"
      data_block_device   = var.data_block_device_name
      mount_point         = var.data_block_device_mount_point
      mongodb_nproc       = base64encode(file("${path.module}/scripts/99-mongodb-nproc.conf"))
      bootstrap           = base64encode(file("${path.module}/scripts/bootstrap.sh"))
      download_url        = "${var.mms_repo}${var.mms_rpm}"
      disable_thp_service = base64encode(file("${path.module}/scripts/disable-thp.service"))
      genkey              = random_password.genkey.result
      cert_pem            = base64encode(module.https_cert[each.key].cert_pem)
      ca_cert_pem         = base64encode(var.ca_cert_pem)
      fqdn                = local.create_zone_record ? each.value["fqdn"] : null
      authorized_key      = trimspace(var.ssh_authorized_key)

      readahead_service   = base64encode(templatefile("${path.module}/templates/readahead.service", {
        data_block_device  = var.data_block_device_name
      }))
      conf_mms            = base64encode(templatefile("${path.module}/templates/conf-mms.properties", {
        mongo_uri          = var.appdb_mongo_uri
        enable_https       = var.enable_https
        mms_url            = local.mms_central_url
      }))
    })
  }
}

resource "aws_security_group" "main" {
  name_prefix = "${var.name}-mms-sg-"
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

resource "aws_security_group_rule" "http" {
  count = var.enable_https ? 0: 1
  type = "ingress"
  from_port = 8080
  to_port = 8080
  protocol = "tcp"
  description = "http"
  cidr_blocks = var.web_ingress_cidr
  security_group_id = aws_security_group.main.id
}

resource "aws_security_group_rule" "https" {
  count = var.enable_https ? 1: 0
  type = "ingress"
  from_port = 8443
  to_port = 8443
  protocol = "tcp"
  description = "https"
  cidr_blocks = var.web_ingress_cidr
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

resource "random_password" "genkey" {
  length = 24
  special = true
}

module "https_cert" {
  for_each = local.instances
  source   = "../tls-certs"

  ca_cert_pem         = var.ca_cert_pem
  ca_private_key_pem  = var.ca_private_key_pem
  organizational_unit = "om"
  common_name         = each.value["fqdn"]
  dns_names           = [local.mms_central_dns, each.value["fqdn"]]
  allowed_uses        = [
    "key_encipherment",
    "digital_signature",
    "server_auth"
  ]
}

resource "aws_lb" "main" {
  count              = var.create_nlb ? 1: 0

  name               = "${var.name}-mms-lb"
  internal           = false
  load_balancer_type = "network"
  subnets            = var.subnet_ids

  tags = var.tags
}

resource "aws_lb_target_group" "main" {
  count    = var.create_nlb ? 1: 0

  name     = "${var.name}-mms-tg"
  port     = var.enable_https ? 443 : 80
  protocol = "TCP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_target_group_attachment" "main" {
  for_each = var.create_nlb ? local.instances : {}

  target_group_arn = aws_lb_target_group.main[0].arn
  target_id        = aws_instance.main[each.key].id
  port             = var.enable_https ? 8443 : 8080
}

resource "aws_lb_listener" "main" {
  count = var.create_nlb ? 1 : 0

  load_balancer_arn = aws_lb.main[0].arn
  port              = var.enable_https ? "443" : "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main[0].arn
  }
}

resource "aws_route53_record" "lb" {
  count = var.create_nlb && local.create_zone_record ? 1: 0

  zone_id = var.zone_id
  name    = local.zone_central_dns
  type    = "A"

  alias {
    name                   = aws_lb.main[0].dns_name
    zone_id                = aws_lb.main[0].zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "instance_group" {
  count = !var.create_nlb && local.create_zone_record ? 1: 0

  zone_id = var.zone_id
  name    = local.zone_central_dns
  type    = "A"
  ttl     = "300"

  records = values(aws_instance.main)[*].public_ip
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
