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

variable "environment" {
  type        = string
  default     = ""
  description = "Environment, e.g. 'prd', 'qa', 'dev'"
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