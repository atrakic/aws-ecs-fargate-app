import boto3

sts_client = boto3.client("sts")


def aws_whoami():
    response = sts_client.get_caller_identity()
    response.pop("ResponseMetadata", None)
    return response
