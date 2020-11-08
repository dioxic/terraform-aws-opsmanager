output "public_ip" {
  value = values(aws_instance.main)[*].public_ip
}

output "public_dns" {
  value = values(aws_instance.main)[*].public_dns
}

output "mms_url" {
  value = local.mms_central_url
}

output "lb_dns" {
  value = var.create_nlb ? aws_lb.main[0].dns_name : null
}

output "zone_dns" {
  value = values(aws_route53_record.instance)[*].fqdn
}

output "zone_central_dns" {
  value = concat(aws_route53_record.instance_group[*].fqdn, aws_route53_record.lb[*].fqdn)
}