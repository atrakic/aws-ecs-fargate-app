import os
import boto3
import botocore

aws_region = os.getenv("AWS_DEFAULT_REGION", default="us-east-1")
aws_endpoint_url = os.environ.get("AWS_ENDPOINT_URL", None)

if aws_endpoint_url is not None:
    sns = boto3.client("sns", region_name=aws_region, endpoint_url=aws_endpoint_url)
else:
    sns = boto3.client("sns")


def publish_message(topic_arn, message):
    try:
        response = sns.publish(TopicArn=topic_arn, Message=message)
        message_id = response["MessageId"]
    except botocore.exceptions.ClientError as err:
        raise err

    return message_id


def list_subscriptions(topic_arn):
    response = sns.list_subscriptions_by_topic(TopicArn=topic_arn)
    subscriptions = response["Subscriptions"]
    return subscriptions
