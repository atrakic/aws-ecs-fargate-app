import os
import botocore
import boto3

aws_region = os.getenv("AWS_DEFAULT_REGION", default="us-east-1")
sqs = boto3.client("sqs", region_name=aws_region)


def send_message(queue_url, message_body):
    try:
        response = sqs.send_message(QueueUrl=queue_url, MessageBody=message_body)

    except botocore.exceptions.ClientError as err:
        if err.response["Error"]["Code"] == "InternalError":  # Generic error
            print(f"Error Message: {err.response['Error']['Message']}")
            print(f"Request ID: {err.response['ResponseMetadata']['RequestId']}")
            print(f"Http code: {err.response['ResponseMetadata']['HTTPStatusCode']}")
        else:
            raise err

    return response["MessageId"]


def receive_messages(queue_url, max_messages=1):
    response = sqs.receive_message(QueueUrl=queue_url, MaxNumberOfMessages=max_messages)
    messages = response.get("Messages", [])
    return messages


def delete_message(queue_url, receipt_handle):
    sqs.delete_message(QueueUrl=queue_url, ReceiptHandle=receipt_handle)
