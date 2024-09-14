locals {
  name = "tf-${basename(path.cwd)}"

  # Localstack requires license key to be set to "localstack" to enable pro features
  # https://docs.localstack.cloud/user-guide/aws/feature-coverage/
  localstack_enabled = data.aws_caller_identity.current.account_id == "000000000000" ? true : false

  cidr = "10.0.0.0/16"
  azs  = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = merge(var.tags, {
    Workspace = terraform.workspace
    Owner     = data.aws_caller_identity.current.id
  })
}
