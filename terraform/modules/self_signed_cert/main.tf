variable "tags" {
  type    = map(string)
  default = {}
}

variable "enabled" {
  type    = bool
  default = true
}

variable "subject" {
  type = object({
    common_name         = string
    organization        = string
    organizational_unit = string
  })
  default = {
    common_name         = "example.com"
    organization        = "Example, Inc"
    organizational_unit = "Engineering"
  }
}

resource "tls_private_key" "this" {
  count     = var.enabled ? 1 : 0
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "this" {
  count = var.enabled ? 1 : 0

  private_key_pem = tls_private_key.this[0].private_key_pem
  subject {
    common_name         = var.subject.common_name
    organization        = var.subject.organization
    organizational_unit = var.subject.organizational_unit
  }

  validity_period_hours = 24 * 30
  early_renewal_hours   = 24

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "aws_acm_certificate" "this" {
  count = var.enabled ? 1 : 0

  private_key      = tls_private_key.this[0].private_key_pem
  certificate_body = tls_self_signed_cert.this[0].cert_pem
  tags             = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

output "acm_certificate_arn" {
  description = "The ARN of the certificate"
  //value = join("", [for i in aws_acm_certificate.this : i.id])
  value = try(aws_acm_certificate.this[0].arn, "")
}

output "acm_certificate_status" {
  description = "Status of the certificate."
  value       = try(aws_acm_certificate.this[0].status, "")
}
