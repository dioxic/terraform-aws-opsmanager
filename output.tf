output "webapp_public_ip" {
  value = module.webapp.public_ip
}

output "webapp_public_dns" {
  value = module.webapp.public_dns
}

output "node_public_ip" {
  value = module.nodes.public_ip
}

output "node_public_dns" {
  value = module.nodes.public_dns
}

output "mms_url" {
  value = module.webapp.mms_url
}

output "webapp_zone_dns" {
  value = module.webapp.zone_dns
}

output "node_zone_dns" {
  value = module.nodes.zone_dns
}