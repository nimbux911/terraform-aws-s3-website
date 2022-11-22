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