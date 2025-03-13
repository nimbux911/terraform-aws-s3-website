variable "website_name" {
  type        = string
  default     = ""
  description = "Solution name, e.g. 'app' or 'jenkins'"
}

variable "custom_subdomain" {
  type        = string
  default     = ""
  description = "Custom subdomain name for the website"
}

variable "aliases" {
  type        = list(string)
  description = "A list of alternate domain names"
  default     = []
}

variable "allowed_methods" {
  type     = list(string)
  default  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
}

variable "cached_methods" {
  type     = list(string)
  default = ["GET", "HEAD"]
}

variable "index_document" {
  type    = string
  default = "index.html"
}

variable "error_document" {
  type    = string
  default = "index.html"
}

variable "bucket_name" {
  type        = string
  default     = ""
}

variable "certificate_arn" {
  type        = string
  description = "AWS ACM Certificate arn"
}

variable "domain_name" {
  type        = string
  description = "Domain name"
}

variable "zone_id" {
  type        = string
  description = "AWS Route 53 Hosted Zone id"
}

variable "create_alias_records" {
  type        = bool
  description = "Put in true or false if you want to create alias records"
  default     = true
}

variable "minimum_protocol_version" {
  type        = string
  description = "Protocol version"
  default     = "TLSv1"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "S3 bucket's tags"
}

variable "custom_error_responses" {
  default = []
  type    = list(object({
    error_caching_min_ttl = number
    error_code            = number
    response_code         = number
    response_page_path    = string
  }))
  
}

variable "ordered_cache_behaviors" {
  default = []
  type    = list(object({
    allowed_methods       = list(string)
    cached_methods        = list(string)
    path_pattern          = string
    function_associations = list(object({
      event_type   = string
      function_arn = string
    }))
  }))
}

variable "block_public_acls" {
  type    = bool
  default = true
}

variable "block_public_policy" {
  type    = bool
  default = true
}

variable "ignore_public_acls" {
  type    = bool
  default = true
}

variable "restrict_public_buckets" {
  type    = bool
  default = true
}

variable "custom_origin_configuration" {
  type = object({
    http_port                = number
    https_port               = number
    origin_keepalive_timeout = number
    origin_protocol_policy   = string
    origin_read_timeout      = number
    origin_ssl_protocols     = list(string)
  })

  default = null
}

variable "lambda_config" {
  description = "Lambda function configuration"
  type = object({
    create_lambda      = bool
    lambda_name        = string
    lambda_role        = string
    lambda_file        = string
    lambda_description = string
    lambda_env_vars    = map(string)
    lambda_handler     = string
    lambda_runtime     = string
    lambda_timeout     = number
    lambda_memory_size = number
  })
  default = null
}
