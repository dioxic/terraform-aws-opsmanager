output "public_ip" {
  value = values(aws_instance.main)[*].public_ip
}

output "public_dns" {
  value = values(aws_instance.main)[*].public_dns
}

output "zone_dns" {
  value = values(aws_route53_record.instance)[*].fqdn
}