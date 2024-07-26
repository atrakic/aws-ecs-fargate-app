import os
import boto3

aws_region = os.getenv("AWS_DEFAULT_REGION", default='us-east-1')
sqs = boto3.client("sqs", region_name=aws_region)


def send_message(queue_url, message_body):
    response = sqs.send_message(QueueUrl=queue_url, MessageBody=message_body)
    return response["MessageId"]


def receive_messages(queue_url, max_messages=1):
    response = sqs.receive_message(
        QueueUrl=queue_url,
        MaxNumberOfMessages=max_messages)
    messages = response.get("Messages", [])
    return messages


def delete_message(queue_url, receipt_handle):
    sqs.delete_message(QueueUrl=queue_url, ReceiptHandle=receipt_handle)
