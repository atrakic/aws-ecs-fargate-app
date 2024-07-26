module "self_signed_cert" {
  source  = "./modules/self_signed_cert"
  enabled = var.alb_tls_cert_arn == "" ? true : false
  tags    = var.tags
}
