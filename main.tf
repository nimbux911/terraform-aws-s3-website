locals {
  custom_subdomain = var.custom_subdomain == "" ? var.domain_name : "${var.custom_subdomain}.${var.domain_name}"
}

#
# S3 Website
#
resource "aws_s3_bucket" "website" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.website.bucket

  index_document {
    suffix = var.index_document
  }

  error_document {
    key = var.error_document
  }
}

#
# CloudFront Distribution
#

resource "aws_cloudfront_origin_access_identity" "default" {
  comment = "Origin Access Identity for ${var.website_name} S3 website"
}

resource "aws_cloudfront_distribution" "default" {
  origin {
    domain_name = aws_s3_bucket.website.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.website.bucket

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.default.cloudfront_access_identity_path
    }
  }

  aliases = var.aliases == [] ? [ local.custom_subdomain ] : concat(var.aliases, [ local.custom_subdomain ])

  default_cache_behavior {
    allowed_methods  = var.allowed_methods
    cached_methods   = var.cached_methods
    target_origin_id = aws_s3_bucket.website.bucket

    forwarded_values {
		  query_string = true
		  cookies {
			  forward = "all"
		  }
	  }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = "0"
    default_ttl            = "3600"
    max_ttl                = "86400"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  price_class         = "PriceClass_All"
  enabled             = true
  default_root_object = "index.html"

  viewer_certificate {
    acm_certificate_arn = var.certificate_arn
    ssl_support_method  = "sni-only"
  }

  custom_error_response {
    error_caching_min_ttl = 10
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
  }

  custom_error_response {
    error_caching_min_ttl = 10
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
  }

}

#
# Bucket policy for Cloudfront OIA
#
data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.website.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.default.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "website" {
  bucket = aws_s3_bucket.website.id
  policy = data.aws_iam_policy_document.s3_policy.json
}

#
# Route 53 Records
#

resource "aws_route53_record" "website" {
  zone_id = var.zone_id
  name    = local.custom_subdomain
  type    = "A"

  alias {
    name    = aws_cloudfront_distribution.default.domain_name
    zone_id = aws_cloudfront_distribution.default.hosted_zone_id
    evaluate_target_health = false
  }
}


resource "aws_route53_record" "aliases" {
  for_each = toset(var.aliases)
  zone_id = var.zone_id
  name    = each.value
  type    = "A"

  alias {
    name    = aws_cloudfront_distribution.default.domain_name
    zone_id = aws_cloudfront_distribution.default.hosted_zone_id
    evaluate_target_health = false
  }
}
