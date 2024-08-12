import botocore
import boto3

sts_client = boto3.client("sts")


def aws_whoami():
    try:
        response = sts_client.get_caller_identity()
        response.pop("ResponseMetadata", None)
        return response
    except botocore.exceptions.ClientError as e:
        return {"error": str(e)}
