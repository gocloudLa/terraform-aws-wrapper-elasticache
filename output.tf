
# output "elasticache" {
#   value = module.elasticache
# }

output "aws_route53_record" {
  description = "Alias DNS Records"
  value       = { for k, v in aws_route53_record.elasticache : k => v.fqdn }

}