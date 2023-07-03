# AWS S3 Bucket Website with CloudFront Distribution
Terraform module which creates a private S3 bucket website with a CloudFront Distribution in AWS. Also, creates Route 53 DNS records for desired custom subdomain and each of the aliases.

## Notice
In case of not sending a custom subdomain, it will try to create an A record for the domain name pointing to the CloudFront Distribution

## Usage

#### Terraform required version >= 0.14.8

## Private S3 Bucket Website + CloudFront Distribution


```hcl

module "s3_website" {
  source       = "github.com/nimbux911/terraform-aws-s3-website.git?ref=v1.0"

  website_name = "my-awesome-website"
  bucket_name  = "nimbux911-static-awesome-website-bucket"

  index_document  = "index.html"
  error_document  = "error.html"
  allowed_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
  cached_methods  = ["GET", "HEAD"]
  certificate_arn = "arn:aws:acm:us-east-1:123456789:certificate/32fgh45d-a24c-430e-a9f0-7e4508d21b9c"

  zone_id              = "NIMBUX911"
  domain_name          = "nimbux911.com"
  custom_subdomain     = "awesome"
  aliases              = ["tooawesome.nimbux911.com", "reallyawesome.nimbux911.com"]
  create_alias_records = true
  minimum_protocol_version = "TLSv1"
} 

```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bucket\_name | S3 bucket name. | `string` | `""` | yes |
| website\_name | Website name. | `string` | `""` | yes |
| custom\_subdomain | Custom subdomain name for the website. | `string` | `""` | no |
| aliases | A list of alternate domain names. | `list(string)` | `[]` | no |
| allowed\_methods | List of allower methods.  | `list(string)` | `["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]` | no |
| cached\_methods | List of cached methods. | `list(string)` | `["GET", "HEAD"]` | no |
| index\_document | The name of the index document for the website. | `string` | `index.html` | no |
| error\_document | The name of the error document for the website. | `string` | `index.html` | no |
| certificate\_arn | AWS ACM Certificate arn. | `string` | `null` | yes |
| domain\_name | Domain name. | `string` | `null` | yes |
| zone\_id | AWS Route 53 Hosted Zone id. | `string` | `null` | yes |
| create\_alias\_records | Enable or not the creation of alias records | `bool` | `true` | no |
| minimum\_protocol\_version | Minimum version of the SSL protocol that you want CloudFront to use for HTTPS connections | `string` | `TLSv1` | no |


## Outputs

| Name | Description |
|------|-------------|
| cf\_id | ID of AWS CloudFront distribution. |
| cf\_arn | ARN of AWS CloudFront distribution. |
| cf\_status | Current status of the distribution. |
| cf\_domain\_name | Domain name corresponding to the distribution. |
| s3\_bucket | Website S3 bucket. |

