import os
import boto3

dynamodb = boto3.client("dynamodb")
table = os.environ.get("TABLE_NAME", "YourTestTable")


def get_items():
    return dynamodb.scan(TableName=table)
