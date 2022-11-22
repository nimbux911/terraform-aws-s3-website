output "cf_id" {
  value       = aws_cloudfront_distribution.default.id
  description = "ID of AWS CloudFront distribution"
}

output "cf_arn" {
  value       = aws_cloudfront_distribution.default.arn
  description = "ARN of AWS CloudFront distribution"
}

output "cf_status" {
  value       = aws_cloudfront_distribution.default.status
  description = "Current status of the distribution"
}

output "cf_domain_name" {
  value       = aws_cloudfront_distribution.default.domain_name
  description = "Domain name corresponding to the distribution"
}

output "s3_bucket" {
  value       = aws_s3_bucket.website.bucket
  description = "Website S3 bucket"
}

