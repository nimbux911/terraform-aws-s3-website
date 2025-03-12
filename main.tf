locals {
  custom_subdomain       = var.custom_subdomain == "" ? var.domain_name : "${var.custom_subdomain}.${var.domain_name}"
  aliases                = var.aliases != [] ? toset([for alias in toset(var.aliases): "${alias}"]) : []
  custom_error_responses = length(var.custom_error_responses) > 0 ? var.custom_error_responses : [
    {
      error_caching_min_ttl = 10
      error_code            = 403
      response_code         = 200
      response_page_path    = "/index.html"
    },
    {
      error_caching_min_ttl = 10
      error_code            = 404
      response_code         = 200
      response_page_path    = "/index.html"
    }
  ]
}

#
# S3 Website
#
resource "aws_s3_bucket" "website" {
  bucket = var.bucket_name
  tags   = var.tags
}

resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
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

    dynamic custom_origin_config {
      for_each = var.custom_origin_configuration == null ? [] : [var.custom_origin_configuration]

      content {
            http_port                = var.custom_origin_configuration.http_port
            https_port               = var.custom_origin_configuration.https_port
            origin_keepalive_timeout = var.custom_origin_configuration.origin_keepalive_timeout
            origin_protocol_policy   = var.custom_origin_configuration.origin_protocol_policy
            origin_read_timeout      = var.custom_origin_configuration.origin_read_timeout
            origin_ssl_protocols     = var.custom_origin_configuration.origin_ssl_protocols
        }
     }
  }

  aliases = var.aliases == [] ? [ local.custom_subdomain ] : concat(tolist(local.aliases), [ local.custom_subdomain ])

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
    acm_certificate_arn       = var.certificate_arn
    ssl_support_method        = "sni-only"
    minimum_protocol_version  = var.minimum_protocol_version
  }

  dynamic "custom_error_response" {
    for_each = local.custom_error_responses
    content {
      error_caching_min_ttl = custom_error_response.value.error_caching_min_ttl
      error_code            = custom_error_response.value.error_code
      response_code         = custom_error_response.value.response_code
      response_page_path    = custom_error_response.value.response_page_path
    }
  }

  dynamic "ordered_cache_behavior" {
    for_each = var.ordered_cache_behaviors
    content {
      allowed_methods        = ordered_cache_behavior.value.allowed_methods
      cached_methods         = ordered_cache_behavior.value.cached_methods
      path_pattern           = ordered_cache_behavior.value.path_pattern
      target_origin_id       = aws_s3_bucket.website.bucket
      viewer_protocol_policy = "redirect-to-https"

      forwarded_values {
        query_string = false
          cookies {
            forward = "none"
          }
      }
      
      dynamic "function_association" {
        for_each = ordered_cache_behavior.value.function_associations
        content {
          event_type   = function_association.value.event_type
          function_arn = function_association.value.function_arn
        }
      }
    }
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
  for_each = var.create_alias_records ? local.aliases : []
  zone_id  = var.zone_id
  name     = each.value
  type     = "A"

  alias {
    name    = aws_cloudfront_distribution.default.domain_name
    zone_id = aws_cloudfront_distribution.default.hosted_zone_id
    evaluate_target_health = false
  }
}

#
# Lambda functions
#

resource "aws_lambda_function" "website" {
  count         = var.create_lambda ? 1 : 0
  function_name = var.lambda_name
  role          = var.lambda_role
  filename      = var.lambda_file
  handler       = "index.handler"
  runtime       = "python3.8"
  
}

#"arn:aws:iam::<your-account-id>:role/iam-r-s3-web-static-prd"